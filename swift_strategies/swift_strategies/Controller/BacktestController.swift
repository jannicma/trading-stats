//
//  BacktestController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 18.07.2025.
//

struct BacktestController{
    public func runBacktest() async {
        let backtestingStrat: Strategy = TrippleEmaStrategy()
        let evaluationController = EvaluationController()
        let chartController = ChartController()
        let parameterController = ParameterController()
        
        let requiredParameters = backtestingStrat.getRequiredParameters()
        // strategy.getRequiredIndicators
        
        let allCharts = await chartController.getAllChartsWithIndicaors()
        let settings = parameterController.generateParameters(requirements: requiredParameters)
        
        var parameterSets: [(chart: String, settings: ParameterSet)] = []

        for (chartName, _) in allCharts {
            for settig in settings{
                parameterSets.append((chartName, settig))
            }
        }

        let batchSize = 50
        let batches = parameterSets.chunked(into: batchSize)
        
        var batchIndex = 0
        var allEvaluations: [EvaluationModel] = []

        for batch in batches {
            batchIndex += 1
            await withTaskGroup(of: EvaluationModel?.self) { group in
                for (chartName, setting) in batch {
                    group.addTask {
                        var eval = backtestingStrat.backtest(chart: allCharts[chartName]!, paramSet: setting)
                        eval.origin = chartName
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
