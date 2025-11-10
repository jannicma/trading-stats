import AtlasComms
import AtlasCore
import AtlasPlaybook
//
//  LiveTradeController.swift
//  AtlasEngine
//
//  Created by Jannic Marcon on 24.09.2025.
//
import Foundation

public actor LiveTradeManager {
    public static let shared = LiveTradeManager()
    private init() {
        Task { [weak self] in
            guard let self else {
                print("self does not exit in init()")
                return
            }
            await self.initClient()
        }
    }

    //TODO: refactor structs
    private var liveStrategies: [UUID: any Strategy] = [:]
    private var liveParams: [UUID: ParameterSet] = [:]
    private var liveSymbol: [UUID: String] = [:]
    private var liveTimeframe: [UUID: Int] = [:]

    private var client: ExchangeClient?
    private var tradeExecutor: LiveTradeExecutor?

    private var runTimer: DispatchSourceTimer?

    func startMinuteTimer() {
        stopMinuteTimer()

        let timer = DispatchSource.makeTimerSource(queue: .global())
        timer.schedule(deadline: .now().advanced(by: secondsUntilNextMinute()), repeating: 60)
        timer.setEventHandler { [weak self] in
            Task { [weak self] in
                await self?.runAllStrategies()
            }
        }
        runTimer = timer
        timer.resume()
    }

    func stopMinuteTimer() {
        runTimer?.cancel()
        runTimer = nil
    }

    private func secondsUntilNextMinute() -> DispatchTimeInterval {
        let now = Date()
        let calendar = Calendar.current
        let nextMinute = calendar.nextDate(
            after: now,
            matching: DateComponents(second: 0),
            matchingPolicy: .nextTime
        )!
        let interval = nextMinute.timeIntervalSince(now)
        return .milliseconds(Int(interval * 1000))
    }

    public func initDeribitClient() {
        self.client = DeribitClient()  //TODO: add API secret
        self.tradeExecutor = LiveTradeExecutor(client: self.client!)
    }

    private func initClient() async {
        initDeribitClient()
        startMinuteTimer()
    }

    public func addStrategy(
        _ strat: StrategyType, params: ParameterSet, symbol: String, timeframe: Int
    ) -> LiveStrategyOverview {
        let id = UUID()
        let strategy = strat.make(id: id)
        liveStrategies[id] = strategy
        liveParams[id] = params
        liveSymbol[id] = symbol
        liveTimeframe[id] = timeframe

        Task {
            for indicator in strategy.getRequiredIndicators() {
                await client?.addRequiredIndicator(indicator)
            }
            await client?.startChartRefresh(symbols: [symbol], timeframes: [timeframe])
        }

        let overview = LiveStrategyOverview(
            id: id, name: strat.name, parameters: params, symbol: symbol, timeframe: timeframe,
            pnl: 0.0)
        return overview
    }

    public func getLiveStrategies() -> [LiveStrategyOverview] {
        var strategies: [LiveStrategyOverview] = []
        for key in liveStrategies.keys {
            let stratName = type(of: liveStrategies[key]!).name
            let strat = LiveStrategyOverview(
                id: key, name: stratName, parameters: liveParams[key]!, symbol: liveSymbol[key]!,
                timeframe: liveTimeframe[key]!, pnl: 0.0)
            strategies.append(strat)
        }
        return strategies
    }

    private func runAllStrategies() async {
        print("run strategies")
        guard let client, let tradeExecutor, liveStrategies.isEmpty == false else {
            print("no client or strategies")
            return
        }

        var charts: [UUID: Chart] = [:]
        for (id, _) in liveStrategies {
            let tf = liveTimeframe[id]!
            let symbol = liveSymbol[id]!
            let chart = await client.fetchChart(of: symbol, timeframe: tf)!
            charts[id] = chart
        }

        //TODO: add ID to executor to get data for one strategy
        let orders: [Order] = tradeExecutor.getOpenOrders()
        let positions: [Position] = tradeExecutor.getOpenPositions()

        for id in liveStrategies.keys {
            Task {
                await strategyLoop(id, chart: charts[id]!, orders: orders, positions: positions)
            }
        }
    }

    private func strategyLoop(_ id: UUID, chart: Chart, orders: [Order], positions: [Position])
        async
    {
        let strat = liveStrategies[id]!
        let params = liveParams[id]!

        let actions = strat.onCandle(chart, orders: orders, positions: positions, paramSet: params)
        await self.tradeExecutor?.submit(actions)
    }
}
