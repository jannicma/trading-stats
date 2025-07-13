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
        let backtestingStrat: Strategy = TrippleEmaStrategy()
        let evaluationController = EvaluationController()
        
        let allCharts = CsvController.getAllCharts()
        var allEvaluations: [EvaluationModel] = []
        for chart in allCharts {
            print("Backtesting \(chart)")
            var eval = backtestingStrat.backtest(chart: chart)
            eval.origin = chart
            allEvaluations.append(eval)
            print("\n")
        }
        
        evaluationController.evaluateEvaluations(evaluations: allEvaluations)
    }
}
