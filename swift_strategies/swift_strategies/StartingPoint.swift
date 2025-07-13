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
            
            for tpMult in stride(from: 3.0, through: 9.0, by: 0.5){
                for slMult in stride(from: 2.0, through: 6.0, by: 0.5){
                    var eval = backtestingStrat.backtest(chart: chart, tpMult: tpMult, slMult: slMult)
                    eval.origin = chart + "\n tpMult: \(tpMult), slMult: \(slMult)"
                    allEvaluations.append(eval)
                }
            }
        }
        
        evaluationController.evaluateEvaluations(evaluations: allEvaluations)
    }
}
