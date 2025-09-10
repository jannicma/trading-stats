import AtlasCore
import AtlasKit
import AtlasPlaybook
import AtlasVault
//
//  BacktestController.swift
//  AtlasSim
//
//  Created by Jannic Marcon on 23.08.2025.
//
import Foundation

public struct BacktestController {
    public init() {}

    private var allStrategies: [any Strategy] = []
    private let allStrategyNames: [String] = [
        "Tripple SMA Strategy",
        "Stochastic/RSI Strategy",
        "Candle Breakout Strategy",
    ]

    private func createStrategy(for name: String, uuid: UUID) -> any Strategy {
        switch name {
        case "Tripple SMA Strategy":
            return TrippleEmaStrategy(id: uuid)
        case "Stochastic/RSI Strategy":
            return StochRsiStrategy(id: uuid)
        case "Candle Breakout Strategy":
            return CandleBreakoutStrategy(id: uuid)
        default:
            fatalError("Unsupported strategy name: \(name)")
        }
    }

    public mutating func loadAndGetAllStrategies() async -> [any Strategy] {
        let strategyDataService: StrategyDataService = .init()
        var allStrategies: [any Strategy] = []

        do {
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
        let backtestingStrat: any Strategy = allStrategies.filter { $0.id as? UUID == strategyId }
            .first!
        print("Strategy backtest is running now...")

        let parameterController: ParameterGenerator = ParameterGenerator()

        let requiredParameters = backtestingStrat.getRequiredParameters()
        let requiredIndicators = backtestingStrat.getRequiredIndicators()

        let chartController: ChartService = ChartService(indicatorsToCompute: requiredIndicators)

        let allCharts = await chartController.loadAllCharts(timeframes: [1, 3])  // [1, 3, 5, 15, 30]
        let settings = parameterController.generateParameters(requirements: requiredParameters)

        var parameterSets: [(chart: Chart, settings: ParameterSet)] = []

        for setting in settings {
            for chart in allCharts {
                parameterSets.append((chart, setting))
            }
        }
        
        var allEvaluations: [Evaluation] = []
        var pendingRuns = parameterSets.enumerated().makeIterator()
        let convurrencyCores = OsHelpers.defaultConcurrencyCores()
        
        await withTaskGroup(of: Evaluation.self) { group in
            for _ in 0..<min(convurrencyCores, parameterSets.count) {
                if let (_, job) = pendingRuns.next() {
                    group.addTask {
                        return await BacktestController.makeBacktestRun(strategy: backtestingStrat, chart: job.chart, paramSet: job.settings, backtestSettings: backtestSettings)
                    }
                }
            }
            
            while let eval = await group.next() {
                allEvaluations.append(eval)
                if let (_, nextJob) = pendingRuns.next() {
                    group.addTask {
                        return await BacktestController.makeBacktestRun(strategy: backtestingStrat, chart: nextJob.chart, paramSet: nextJob.settings, backtestSettings: backtestSettings)
                    }
                }
            }
        }
        
        if allEvaluations.count < 10 {
            print("Not enough evaluations found, quitting...")
            return allEvaluations.count
        }

        allEvaluations.sort {
            $0.expectancy * Double($0.trades) > $1.expectancy * Double($1.trades)
        }
        Evaluator.evaluateEvaluations(evaluations: allEvaluations)

        let evaluationDataService = EvaluationDataService()
        _ = await evaluationDataService.saveEvaluations(
            allEvaluations, strategy: backtestingStrat.id as! UUID)

        return allEvaluations.count
    }
    
    private static func makeBacktestRun(strategy: any Strategy, chart: Chart, paramSet: ParameterSet, backtestSettings: BacktestSettings) async -> Evaluation {
        var executor = BacktestExecutor()
        
        for i in 0..<chart.candles.count {
            let subChart = chart[i-50..<i+1]
            let currCandle = chart.candles[i]
            let openOrders = executor.getOpenOrders()
            let openPositions = executor.getOpenPositions()
            let actions = strategy.onCandle(subChart, orders: openOrders, positions: openPositions, paramSet: paramSet)
            executor.submit(actions, marketPrice: currCandle.close, time: currCandle.time)
        }
        
        let closedPositions = executor.getAllClosedPositions()
        
        Evaluator.evaluatePositions(closedPositions, fees: backtestSettings.fees)
    }
}
