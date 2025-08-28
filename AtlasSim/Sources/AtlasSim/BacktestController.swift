//
//  BacktestController.swift
//  AtlasSim
//
//  Created by Jannic Marcon on 23.08.2025.
//
import Foundation
import AtlasCore
import AtlasKit
import AtlasPlaybook
import AtlasVault

public struct BacktestController{
    public init() { }
    
    private let allStrategies: [any Strategy] = [
        StochRsiStrategy(),
        TrippleEmaStrategy(),
    ]
    
    public func getAllStrategies() -> [any Strategy] {
        return allStrategies
    }
    
    public func runBacktest(strategyName: String) async -> StrategyEvaluations {
        let backtestingStrat: any Strategy = allStrategies.filter{ $0.name == strategyName }.first!
        print("Strategy backtest is running now...")
        var result = StrategyEvaluations(strategyName: strategyName, evaluations: [])
        
        let parameterController: ParameterGenerator = ParameterGenerator()
        
        let requiredParameters = backtestingStrat.getRequiredParameters()
        let requiredIndicators = backtestingStrat.getRequiredIndicators()
        
        let chartController: ChartService = ChartService(indicatorsToCompute: requiredIndicators)

        let allCharts = await chartController.loadAllCharts(timeframes: [1, 3, 5, 15, 30])
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
        var allEvaluations: [Evaluation] = []
        
        for batch in batches {
            batchIndex += 1
            await withTaskGroup(of: Evaluation.self) { group in
                for (chart, setting) in batch {
                    group.addTask {
                        let trades = backtestingStrat.backtest(chart: chart, paramSet: setting)
                        var eval = Evaluator.evaluateTrades(simulatedTrades: trades)
                        eval.paramSet = setting
                        eval.timeframe = String(chart.timeframe)  //TODO: change to Int
                        eval.symbol = chart.name
                        
                        return eval
                    }
                }
                
                for await eval in group {
                    allEvaluations.append(eval)
                }
            }
            print("batch \(batchIndex)/\(batches.count) done")
        }
        print()
        
        //allEvaluations = allEvaluations.filter { $0.averageRMultiples > 0.15 && $0.maxDrawdown < 10_000 && $0.trades > 50}
        if allEvaluations.count < 10 {
            print("Not enough evaluations found, quitting...")
            return result
        }
        
        
        allEvaluations.sort {$0.expectancy * Double($0.trades) > $1.expectancy * Double($1.trades)}
        
        JsonController.saveToJSON(allEvaluations, filePath: "/Users/jannicmarcon/Documents/Other/evaluations_1.json")
        print()
        Evaluator.evaluateEvaluations(evaluations: allEvaluations)
        
        result.evaluations = allEvaluations
        return result
    }
}
