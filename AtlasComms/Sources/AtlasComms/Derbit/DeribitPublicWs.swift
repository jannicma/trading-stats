import Foundation
import AtlasCore

public actor DeribitPublicWs {
    private var session: URLSession?
    private var socket: URLSessionWebSocketTask?
    private(set) var isConnected = false

    private var pumpTask: Task<Void, Never>?

    private var pingTask: Task<Void, Never>?
    private var lastMessageAt: Date?
    private let heartbeatInterval: TimeInterval = 15
    private let idleTimeout: TimeInterval = 60

    private var continuations: [CandleKey: AsyncThrowingStream<TransferKline, Error>.Continuation] = [:]
    private var refCount: [CandleKey: Int] = [:]
    private var channelToKey: [String: CandleKey] = [:]

    public init() {}

    public func connect(url: URL) async throws {
        if isConnected { return }
        session = URLSession(configuration: .default)
        socket = session?.webSocketTask(with: url)
        socket?.resume()
        isConnected = true
        updateLastMessageTime()

        startPumpLoop()
        startHeartbeat()
    }

    public func subscribeChart(symbol: String, resolution: Int) async throws -> AsyncThrowingStream<
        TransferKline, Error
    > {
        guard isConnected, socket != nil else { throw PublicWsError.notConnected }
        let key = CandleKey(symbol: symbol, resolution: resolution)

        if continuations[key] == nil {
            var cont: AsyncThrowingStream<TransferKline, Error>.Continuation!
            let stream = AsyncThrowingStream<TransferKline, Error> { c in cont = c }
            continuations[key] = cont
            channelToKey[key.channel] = key

            let req: [String: Any] = [
                "jsonrpc": "2.0",
                "id": Int.random(in: 1..<10_000),
                "method": "public/subscribe",
                "params": ["channels": [key.channel]],
            ]
            try await send(json: req)
            refCount[key] = 1
            return stream
        } else {
            refCount[key, default: 0] += 1
            let cont = continuations[key]!
            return AsyncThrowingStream { continuation in
                cont.onTermination = { _ in }
            }
        }
    }

    public func unsubscribeChart(symbol: String, resolution: Int) async throws {
        let key = CandleKey(symbol: symbol, resolution: resolution)
        guard var count = refCount[key], count > 0 else { return }
        count -= 1
        refCount[key] = count

        if count == 0 {
            refCount.removeValue(forKey: key)
            continuations[key]?.finish()
            continuations.removeValue(forKey: key)
            channelToKey.removeValue(forKey: key.channel)

            let req: [String: Any] = [
                "jsonrpc": "2.0",
                "id": Int.random(in: 1..<10_000),
                "method": "public/unsubscribe",
                "params": ["channels": [key.channel]],
            ]
            try await send(json: req)
        }
    }

    public func dissconnect() async {
        pingTask?.cancel()
        pingTask = nil
        pumpTask?.cancel()
        pumpTask = nil

        for (_, cont) in continuations { cont.finish() }
        continuations.removeAll()
        refCount.removeAll()
        channelToKey.removeAll()

        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil
        session?.invalidateAndCancel()
        session = nil
        isConnected = false
    }

    private func startPumpLoop() {
        pumpTask?.cancel()
        pumpTask = Task(priority: .utility) { [weak self] in
            guard let self else { return }
            do {
                while !Task.isCancelled {
                    print("in pump loop")
                    guard let socket = await self.socket else { print("no socket"); break }
                    let msg = try await socket.receive()
                    await self.updateLastMessageTime()
                    switch msg {
                    case .string(let text):
                        if text.contains("pong") { print("pong") }
                        await self.handle(text: text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            await self.handle(text: text)
                        }
                    @unknown default:
                        break
                    }
                }
            } catch is CancellationError {} catch {
                for (_, cont) in await self.continuations { cont.finish(throwing: error) }
                await self.dissconnect()
            }
        }
    }

    private func startHeartbeat() {
        pingTask?.cancel()
        pingTask = Task(priority: .background) { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                let interval = self.heartbeatInterval
                try? await Task.sleep(
                    nanoseconds: UInt64(interval * 1_000_000_000))
                guard let socket = await self.socket else { continue }
                let timeout = self.idleTimeout
                if let last = await self.lastMessageAt,
                    Date().timeIntervalSince(last) > timeout
                {
                    //reconnect
                }

                do {
                    try await socket.send(.string(#"{"jsonrpc":"2.0","method":"public/ping"}"#))
                    print("ping")
                } catch {
                    // exit? i dont know
                }
            }
        }
    }

    private func updateLastMessageTime() {
        lastMessageAt = Date()
    }

    private func handle(text: String) async {
        guard let root = try? JSONSerialization.jsonObject(with: Data(text.utf8)) as? [String: Any]
        else {
            print("empty return")
            return
        }

        if let params = root["params"] as? [String: Any],
            let channel = params["channel"] as? String,
            let data = params["data"] as? [String: Any],
            let key = channelToKey[channel],
            let k = parseKline(channel: channel, data: data)
        {
            continuations[key]?.yield(k)
        }
    }

    private func parseKline(channel: String, data: [String: Any]) -> TransferKline? {
        let parts = channel.split(separator: ".")
        guard parts.count >= 4 else { return nil }
        let symbol = String(parts[2])
        let res = Int(parts[3])!

        guard
            let o = data["open"] as? Double,
            let h = data["high"] as? Double,
            let l = data["low"] as? Double,
            let c = data["close"] as? Double,
            let v = data["volume"] as? Double,
            let ts = (data["tick"] ?? data["timestamp"]) as? Int
        else { return nil }

        return TransferKline(
            symbol: symbol,
            resolution: res,
            time: ts,
            open: Decimal(o),
            high: Decimal(h),
            low: Decimal(l),
            close: Decimal(c),
            volume: Decimal(v),
            isFinal: (data["isFinal"] as? Bool) ?? false
        )
    }

    private func send(json: [String: Any]) async throws {
        guard let socket else { throw PublicWsError.notConnected }
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        guard let text = String(data: data, encoding: .utf8) else {
            throw PublicWsError.invalidMessage("encoding json")
        }
        try await socket.send(.string(text))
    }
}
