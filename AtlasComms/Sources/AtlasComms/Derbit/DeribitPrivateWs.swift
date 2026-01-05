import AtlasCore
import Foundation

public actor DeribitPrivateWs {
    private var session: URLSession?
    private var socket: URLSessionWebSocketTask?
    private(set) var isConnected = false

    private var pingTask: Task<Void, Never>?
    private var lastMessageAt: Date?
    private let heartbeatInterval: TimeInterval = 15
    private let idleTimeout: TimeInterval = 60

    public init() {}

    public func connect(url: URL) async throws {
        if isConnected { return }
        session = URLSession(configuration: .default)
        socket = session?.webSocketTask(with: url)
        socket?.resume()
        isConnected = true
        updateLastMessageTime()

        startHeartbeat()
    }

    private func updateLastMessageTime() {
        lastMessageAt = Date()
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
                } catch {
                    // exit? i dont know
                }
            }
        }
    }

    public func createOrder(order: Order) {
        // jsonrpc call
    }

    public func dissconnect() async {
        print("dissconnect web socket")
        pingTask?.cancel()
        pingTask = nil

        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil
        session?.invalidateAndCancel()
        session = nil
        isConnected = false
    }

}
