//
//  LiveTradeController.swift
//  AtlasEngine
//
//  Created by Jannic Marcon on 24.09.2025.
//
import Foundation
import AtlasComms
import AtlasCore
import AtlasPlaybook

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
    
    private var liveStrategies: [UUID: any Strategy] = [:]
    private var liveParams: [UUID: ParameterSet] = [:]
    
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
        self.client = DeribitClient() //TODO: add API secret
        
        self.tradeExecutor = LiveTradeExecutor(client: self.client!)
    }
    
    private func initClient() async {
        initDeribitClient()
        startMinuteTimer()
    }
    
    public func addStrategy(_ strat: StrategyType, params: ParameterSet) -> LiveStrategyOverview {
        let id = UUID()
        let strategy = strat.make(id: id)
        liveStrategies[id] = strategy
        liveParams[id] = params
        
        let overview = LiveStrategyOverview(id: id, name: strat.name, parameters: params, pnl: 0.0)
        return overview
    }
    
    public func getLiveStrategies() -> [LiveStrategyOverview] {
        var strategies: [LiveStrategyOverview] = []
        for key in liveStrategies.keys {
            let stratName = type(of: liveStrategies[key]!).name
            let strat = LiveStrategyOverview(id: key, name: stratName, parameters: liveParams[key]!, pnl: 0.0)
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
        
        let oneMinChart = await client.fetchChart(of: "BTC-PERPETUAL", timeframe: 1)!
        let orders: [Order] = tradeExecutor.getOpenOrders()
        let positions: [Position] = tradeExecutor.getOpenPositions()
        
        for id in liveStrategies.keys {
            Task{
                await strategyLoop(id, chart: oneMinChart, orders: orders, positions: positions)
            }
        }
    }
    
    private func strategyLoop(_ id: UUID, chart: Chart, orders: [Order], positions: [Position]) async {
        let strat = liveStrategies[id]!
        let params = liveParams[id]!
        
        let actions = strat.onCandle(chart, orders: orders, positions: positions, paramSet: params)
        await self.tradeExecutor?.submit(actions)
    }
}

