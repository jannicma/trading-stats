//
//  BacktestViewModel.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 24.08.2025.
//

import SwiftUI
import AtlasCore
import AtlasSim

final class BacktestViewModel: ObservableObject {
    @Published var strategies: [any Strategy] = []
    private let backtestController: BacktestController
    
    init() {
        backtestController = BacktestController()
        strategies = backtestController.getAllStrategies()
    }
}
