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
        var backtestingStrat: Strategy = TrippleEmaStrategy()
        backtestingStrat.backtest()
    }

}
