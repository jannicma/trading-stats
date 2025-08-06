//
//  BacktestControllerTests.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

import Testing
@testable import swift_strategies_framework

struct BacktestControllerTests {
    private func getTestChart() async -> Chart {
        var chartController = ChartController()
        chartController.setRequiredIndicators([Indicator.sma(period: 5)])
        let charts = await chartController.loadTestCharts()
        return charts.filter { $0.name == "test_5m" }.first!
    }
    
    @Test func runBacktest() async throws {
        let initChart = await getTestChart()
        var chartController = ChartController()
        let requiredIndicators = [
            Indicator.sma(period: 5),
            Indicator.sma(period: 50),
            Indicator.atr(length: 14),
            Indicator.atr(length: 5)
        ]
        chartController.setRequiredIndicators(requiredIndicators)
        
        let calculatedChart = await chartController.loadAllCharts(initChartsForTesting: [initChart.name: initChart.candles])
        #expect(true)
    }

}
