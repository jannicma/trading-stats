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
    
    private var allStrategies: [any Strategy] = []
    private let allStrategyNames: [String] = [
        "Tripple SMA Strategy",
        "Stochastic/RSI Strategy"
    ]
    
    private func createStrategy(for name: String, uuid: UUID) -> any Strategy {
        switch name {
        case "Tripple SMA Strategy":
            return TrippleEmaStrategy(id: uuid)
        case "Stochastic/RSI Strategy":
            return StochRsiStrategy(id: uuid)
        default:
            fatalError("Unsupported strategy name: \(name)")
        }
    }
    
    
    public mutating func loadAndGetAllStrategies() async -> [any Strategy] {
        let strategyDataService: StrategyDataService = .init()
        var allStrategies: [any Strategy] = []
        
        do{
            for name in allStrategyNames {
                let uuid = try await strategyDataService.getOrCreateStrategyUuid(for: name)
                let strat = createStrategy(for: name, uuid: uuid)
                allStrategies.append(strat)
            }
        } catch {
            let message = "Failed to load strategy UUIDs: \(error.localizedDescription)"
            await AtlasLogger.shared.log(message, level: .error)
        }
        
        self.allStrategies = allStrategies
        return allStrategies
    }
    
    
    public func getEvaluations(for strategy: UUID) async -> [Evaluation] {
        let evalDataService = EvaluationDataService()
        let evals = try? await evalDataService.getAllEvaluations(for: strategy)
        return evals ?? []
    }
    
    
    public func loadEquityCurve(of backtestRun: Int) async -> [EquityPoint] {
        let evaluationDataService = EvaluationDataService()
        let curve = try? await evaluationDataService.getEquityCurve(of: backtestRun)
        return curve ?? []
    }
    
    
    public func runBacktest(strategyId: UUID, backtestSettings: BacktestSettings) async -> Int {
        let backtestingStrat: any Strategy = allStrategies.filter{ $0.id as? UUID == strategyId }.first!
        print("Strategy backtest is running now...")
        
        let parameterController: ParameterGenerator = ParameterGenerator()
        
        let requiredParameters = backtestingStrat.getRequiredParameters()
        let requiredIndicators = backtestingStrat.getRequiredIndicators()
        
        let chartController: ChartService = ChartService(indicatorsToCompute: requiredIndicators)

        let allCharts = await chartController.loadAllCharts(timeframes: [3, 15, 30])   // [1, 3, 5, 15, 30]
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
                        var eval = Evaluator.evaluateTrades(simulatedTrades: trades, simFees: backtestSettings.fees)
                        eval.paramSet = setting
                        eval.timeframe = chart.timeframe
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
        
        if allEvaluations.count < 10 {
            print("Not enough evaluations found, quitting...")
            return allEvaluations.count
        }
        
        
        allEvaluations.sort {$0.expectancy * Double($0.trades) > $1.expectancy * Double($1.trades)}
        Evaluator.evaluateEvaluations(evaluations: allEvaluations)
        
        let evaluationDataService = EvaluationDataService()
        _ = await evaluationDataService.saveEvaluations(allEvaluations, strategy: backtestingStrat.id as! UUID)
        
        return allEvaluations.count
    }
}
