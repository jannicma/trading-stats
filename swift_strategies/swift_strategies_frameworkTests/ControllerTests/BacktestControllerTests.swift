//
//  BacktestControllerTests.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

import Testing
@testable import swift_strategies_framework

struct BacktestControllerTests {

    @Test func runBacktest() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        var backtestController = BacktestController()
        await backtestController.runBacktest()
        #expect(true)
    }

}
