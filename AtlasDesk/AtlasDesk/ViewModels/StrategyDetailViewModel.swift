//
//  StrategyDetailViewModel.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 24.08.2025.
//
import SwiftUI
import AtlasCore
import AtlasSim

final class StrategyDetailViewModel: ObservableObject {
    @Published var evaluation: StrategyEvaluations
    @Published var results: [BacktestResult] = []
    @Published var selected: BacktestResult?
    
    private let backtestController: BacktestController

    init(evaluation: StrategyEvaluations) {
        self.evaluation = evaluation
        self.backtestController = BacktestController()
        self.results = Self.mockResults()
        self.selected = results.first
    }
    
    func runBacktest() async {
        let simulatedEvaluations = await backtestController.runBacktest(strategyName: evaluation.strategyName)
        
        await MainActor.run {
            self.evaluation = simulatedEvaluations
        }
    }

    func equity(for result: BacktestResult) -> [EquityPoint] {
        var points: [EquityPoint] = []
        var last = 100.0
        for i in 0..<120 {
            // simple randomized equity curve, replace with real data once available
            let drift = result.sharpe.clamped(to: -3...5)
            last += Double.random(in: -3...7) + drift
            points.append(.init(step: i, equity: max(50, last)))
        }
        return points
    }

    private static func mockResults() -> [BacktestResult] {
        return [
            .init(timeframe: "2015–2020", asset: "ES Futures", sharpe: 1.21, drawdown: 0.19, expectancy: 0.42, winRate: 0.57, trades: 320),
            .init(timeframe: "2020–2023", asset: "NQ Futures", sharpe: 0.98, drawdown: 0.23, expectancy: 0.35, winRate: 0.53, trades: 275),
            .init(timeframe: "2018–2025", asset: "SPY", sharpe: 1.05, drawdown: 0.17, expectancy: 0.31, winRate: 0.55, trades: 410)
        ]
    }
}
