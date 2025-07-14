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
        let chartController = ChartController()
        
        let allCharts = await chartController.getAllChartsWithIndicaors()
        
        var parameterSets: [(chart: String, tpMult: Double, slMult: Double)] = []

        for (chartName, _) in allCharts {
            for tpMult in stride(from: 3.0, through: 9.0, by: 0.5) {
                for slMult in stride(from: 2.0, through: 6.0, by: 0.5) {
                    parameterSets.append((chartName, tpMult, slMult))
                }
            }
        }

        let batchSize = 50
        let batches = parameterSets.chunked(into: batchSize)
        
        var batchIndex = 0
        var allEvaluations: [EvaluationModel] = []

        for batch in batches {
            batchIndex += 1
            await withTaskGroup(of: EvaluationModel?.self) { group in
                for (chartName, tpMult, slMult) in batch {
                    group.addTask {
                        var eval = backtestingStrat.backtest(chart: allCharts[chartName]!, tpMult: tpMult, slMult: slMult)
                        eval.origin = chartName + "\n tpMult: \(tpMult), slMult: \(slMult)"
                        return eval
                    }
                }

                for await eval in group {
                    if let eval = eval {
                        allEvaluations.append(eval)
                    }
                }
            }
            print("batch \(batchIndex)/\(batches.count) done")
        }

        allEvaluations.sort(by: { $0.averageRMultiples > $1.averageRMultiples })
        
        JsonController.saveEvaluationsToJson(objects: allEvaluations, filename: "/Users/jannicmarcon/Documents/Other/evaluations_1.json")
        evaluationController.evaluateEvaluations(evaluations: allEvaluations)
    }
}
