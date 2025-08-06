//
//  BacktestController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

public struct BacktestController{
    public init() { }
    
    public func runBacktest() async {
        let backtestingStrat: Strategy = TrippleEmaStrategy()
        let evaluationController = EvaluationController()
        var chartController = ChartController()
        let parameterController = ParameterController()
        
        let requiredParameters = backtestingStrat.getRequiredParameters()
        let requiredIndicators = backtestingStrat.getRequiredIndicators()
        
        chartController.setRequiredIndicators(requiredIndicators)
        let allCharts = await chartController.loadAllCharts()
        let settings = parameterController.generateParameters(requirements: requiredParameters)
        
        var parameterSets: [(chart: Chart, settings: ParameterSet)] = []

        for setting in settings{
            for chart in allCharts{
                parameterSets.append((chart, setting))
            }
        }

        let batchSize = 50
        let batches = parameterSets.chunked(into: batchSize)
        
        var batchIndex = 0
        var allEvaluations: [EvaluationModel] = []

        for batch in batches {
            batchIndex += 1
            await withTaskGroup(of: EvaluationModel?.self) { group in
                for (chart, setting) in batch {
                    group.addTask {
                        var eval = backtestingStrat.backtest(chart: chart, paramSet: setting)
                        eval.origin = chart.name
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
        
        JsonController.saveToJSON(allEvaluations, filePath: "/Users/jannicmarcon/Documents/Other/evaluations_1.json")
        evaluationController.evaluateEvaluations(evaluations: allEvaluations)

    }
}
