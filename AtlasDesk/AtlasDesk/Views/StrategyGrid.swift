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
                    StrategyCard(strategy: binding.wrappedValue)
                        .onTapGesture {
                            openWindow(value: binding.wrappedValue)
                        }
                }
            }
            .padding(20)
        }
        .navigationTitle("Backtest Strategies")
    }
}
