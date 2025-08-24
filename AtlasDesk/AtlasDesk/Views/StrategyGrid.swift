//
//  StrategyGrid.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 24.08.2025.
//
import SwiftUI
import AtlasCore

struct StrategyGrid: View {
    @StateObject private var viewModel = BacktestViewModel()
    @Environment(\.openWindow) private var openWindow
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach($viewModel.strategies.indices, id:\.self ) { i in
                    let binding = $viewModel.strategies[i]
                    let strategyEvaluation = viewModel.getStrategyEvaluation(for: i)
                    StrategyCard(strategy: binding.wrappedValue)
                        .onTapGesture {
                            openWindow(value: strategyEvaluation)
                        }
                }
            }
            .padding(20)
        }
        .navigationTitle("Backtest Strategies")
    }
}
