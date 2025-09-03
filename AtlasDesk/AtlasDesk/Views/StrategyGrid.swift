//
//  StrategyGrid.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 24.08.2025.
//
import SwiftUI
import AtlasCore
import UniformTypeIdentifiers

struct StrategyGrid: View {
    @StateObject private var viewModel = BacktestDashboardViewModel()
    @Environment(\.openWindow) private var openWindow
    @StateObject private var importSheetVM = CsvImportViewModel()
    
    @State private var showingImportSheet = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button("Import CSV") {
                    showingImportSheet = true
                }
                .keyboardShortcut("i", modifiers: [.command])
            }
            .padding([.top, .horizontal], 20)

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
        }
        .sheet(isPresented: $showingImportSheet) {
            CsvImportForm(viewModel: importSheetVM)
        }
        .navigationTitle("Backtest Strategies")
    }
}




#Preview {
    StrategyGrid()
}
