//
//  LiveTradeController.swift
//  AtlasEngine
//
//  Created by Jannic Marcon on 24.09.2025.
//
import Foundation
import AtlasComms
import AtlasCore

public actor LiveTradeManager {
    public var shared = LiveTradeManager()
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
    private var runTimer: Timer?
    
    public func initDeribitClient() async {
        self.client = DeribitClient() //TODO: add API secret
        self.tradeExecutor = LiveTradeExecutor(client: self.client!)
        await initClient()
    }
    
    private func initClient() async {
        await scheduleMinuteTimer()
    }
    
    public func addStrategy(_ strat: any Strategy, params: ParameterSet) {
        let id = UUID()
        liveStrategies[id] = strat
        liveParams[id] = params
    }
    
    func scheduleMinuteTimer() async {
        let calendar = Calendar.current
        let now = Date()
        let nextMinute = calendar.nextDate(
            after: now,
            matching: DateComponents(second: 0),
            matchingPolicy: .nextTime)!
        
        let interval = nextMinute.timeIntervalSince(now)
        try? await Task.sleep(for: .seconds(interval))
        self.runTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.runAllStrategies()
            }
        }
    }

    func stopMinuteTimer() {
        runTimer?.invalidate()
        runTimer = nil
    }
    
    private func runAllStrategies() async {
        print("run strategies")

        let oneMinChart = await client!.fetchChart(of: "BTC-PERPETUAL", timeframe: 1)!
        let orders: [Order] = self.tradeExecutor!.getOpenOrders()
        let positions: [Position] = self.tradeExecutor!.getOpenPositions()
        
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
