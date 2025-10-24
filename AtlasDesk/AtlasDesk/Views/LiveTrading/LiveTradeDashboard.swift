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
import AtlasCore
import SwiftUI

struct LiveTradeDashboard: View {
    @State private var showingAddSheet = false
    @StateObject private var vm = LiveTradeDashboardViewModel()

    var body: some View {
        VStack(spacing: 0) {
            tiles
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
    
    private var tiles: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(vm.strategies, id: \.self) { strategy in
                    StrategyTile(strategy: strategy)
                }
            }
            .padding(20)
        }
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]


}

// ================================================================
// MARK: - Preview
// ================================================================
#Preview {
    LiveTradeDashboard()
        .frame(width: 320)
}
