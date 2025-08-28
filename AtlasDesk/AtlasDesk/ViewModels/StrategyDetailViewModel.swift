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
    
    private let backtestController: BacktestController

    init(evaluation: StrategyEvaluations) {
        self.evaluation = evaluation
        self.backtestController = BacktestController()
        self.selected = nil
    }
    
    func runBacktest() async {
        let simulatedEvaluations = await backtestController.runBacktest(strategyName: evaluation.strategyName)
        
        await MainActor.run {
            self.evaluation = simulatedEvaluations
        }
    }
}
