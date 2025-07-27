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
        let chartController = ChartController()
        let charts = await chartController.getTestCharts()
        return charts.filter { $0.name == "test_5m" }.first!
    }
    
    @Test func runBacktest() async throws {
        let chart = await getTestChart()
        #expect(true)
    }

}
