//
//  main.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

import Foundation

@main
struct StartingPoint {
    static func main() async throws {
        let backtestController = BacktestController()
        await backtestController.runBacktest()
    }
}
