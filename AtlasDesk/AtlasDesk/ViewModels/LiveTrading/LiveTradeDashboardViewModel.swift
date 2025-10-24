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
    

    func addStrategy(template: StrategyType, symbol: String) async {
        let newStrategy: LiveStrategyOverview = await tradeManager.addStrategy(template, params: ParameterSet(parameters: []))
        DispatchQueue.main.async { 
            self.strategies.append(newStrategy)
        }
    }
}
