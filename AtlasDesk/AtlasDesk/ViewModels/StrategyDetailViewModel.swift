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
    @Published var selected: Evaluation?
    @Published var makerFee: Double = 0.0000
    @Published var takerFee: Double = 0.0000
    
    private var backtestController: BacktestController

    init(evaluation: StrategyEvaluations) {
        self.evaluation = evaluation
        self.backtestController = BacktestController()
        Task{
            _ = await backtestController.loadAndGetAllStrategies()
            await loadData()
        }
        self.selected = nil
    }
    
    func loadData() async {
        let newEvaluations = await backtestController.getEvaluations(for: evaluation.strategyId!)
        await MainActor.run {
            self.evaluation.evaluations = newEvaluations
        }

    }
    
    func runBacktest() async {
        let fees: SimulatedFees = .init(makerFee: makerFee, takerFee: takerFee)
        let settings: BacktestSettings = .init(fees: fees)
        _ = await backtestController.runBacktest(strategyId: evaluation.strategyId!, backtestSettings: settings)
        await loadData()
    }
    
    func changeSelectedResult() async {
        guard let selectedRun = self.selected else {
            return
        }
        
        if selectedRun.equityCurve.isEmpty {
            let equity = await backtestController.loadEquityCurve(of: selectedRun.id)
            assert(equity.count == selectedRun.trades, "Equity graph does not match number of trades")
            await MainActor.run {
                self.selected?.equityCurve = equity
            }
        }
    }
}
