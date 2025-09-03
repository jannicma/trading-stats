//
//  BacktestViewModel.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 24.08.2025.
//

import SwiftUI
import AtlasCore
import AtlasSim

final class BacktestDashboardViewModel: ObservableObject {
    @Published var strategies: [any Strategy] = []
    private var backtestController: BacktestController
    
    init() {
        backtestController = BacktestController()
        
        Task{
            let strategies = await backtestController.loadAndGetAllStrategies()
            await MainActor.run {
                self.strategies = strategies
            }

        }
    }
    
    func getStrategyEvaluation(for stratIndex: Int) -> StrategyEvaluations {
        let name = strategies[stratIndex].name
        let id = strategies[stratIndex].id
        let evaluation = StrategyEvaluations(strategyName: name, strategyId: id as? UUID, evaluations: [])
        return evaluation
    }
}
