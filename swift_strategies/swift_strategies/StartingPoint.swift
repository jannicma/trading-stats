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
        let chartController = ChartController()
        
        let fixCharts: Bool = false
        
        if fixCharts {
            chartController.fixCharts()
        }else{
            let backtestController = BacktestController()
            await backtestController.runBacktest()
        }

    }
}
