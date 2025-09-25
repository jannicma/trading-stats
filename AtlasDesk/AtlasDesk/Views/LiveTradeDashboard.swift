//
//  LiveTradeDashboard.swift
//  AtlasDesk
//
//  Rebuilt on 24.09.2025
//
//  NOTE: This single source file is structured as if it were split into
//  multiple files (Model, Views, ViewModel). Each section below is labeled
//  with a pseudo-filename to improve readability until we physically split it.
//

import SwiftUI

struct StrategyModel: Identifiable, Hashable {
    let id: UUID
    var name: String
    var profit: Double // running P&L in account currency
    var startedAt: Date
    var symbol: String
    var colorA: Color
    var colorB: Color

    init(id: UUID = UUID(), name: String, profit: Double, startedAt: Date, symbol: String, colorA: Color, colorB: Color) {
        self.id = id
        self.name = name
        self.profit = profit
        self.startedAt = startedAt
        self.symbol = symbol
        self.colorA = colorA
        self.colorB = colorB
    }
}

struct LiveTradeDashboard: View {
    @State private var showingAddSheet = false
    @StateObject private var vm = LiveTradeDashboardViewModel()

    var body: some View {
        VStack(spacing: 0) {
            LiveStrategyGrid(
                strategies: vm.strategies,
                onTap: vm.tapStrategy,
                onOpenLog: vm.openLog,
                onPause: vm.pause,
                onStop: vm.stop
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.background)
        .navigationTitle("Live Strategies")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showingAddSheet = true } label: { Label("Add", systemImage: "plus") }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddStrategySheet(vm: vm)
        }
    }
}

// ================================================================
// MARK: - Preview
// ================================================================
#Preview {
    LiveTradeDashboard()
        .frame(width: 320)
}
