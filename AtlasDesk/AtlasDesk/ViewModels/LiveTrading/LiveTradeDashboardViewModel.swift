//
//  LiveTradeDashboardViewModel.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 25.09.2025.
//
import Foundation
import SwiftUI
import AtlasCore
import AtlasPlaybook
import AtlasEngine

final class LiveTradeDashboardViewModel: ObservableObject, @unchecked Sendable {
    @Published var strategies: [LiveStrategyOverview] = []
    private let tradeManager: LiveTradeManager = LiveTradeManager.shared

    init() {  }

    func addStrategy(strategy: StrategyType, params: ParameterSet, symbol: String, timeframe: Int) async {
        let newStrategy: LiveStrategyOverview = await tradeManager.addStrategy(strategy, params: params, symbol: symbol, timeframe: timeframe)
        DispatchQueue.main.async {
            self.strategies.append(newStrategy)
        }
    }

    func getStrategyParameterDefaults(stratType: StrategyType) -> ParameterSet {
        let strategy = stratType.make(id: UUID())
        let paramRequirements = strategy.getRequiredParameters()
        let params = paramRequirements.map { Parameter(name: $0.name, value: 0.0) }
        return ParameterSet(parameters: params)
    }
}
