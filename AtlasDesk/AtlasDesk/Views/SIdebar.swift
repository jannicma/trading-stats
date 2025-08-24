//
//  SIdebar.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 24.08.2025.
//
import SwiftUI

struct Sidebar: View {
    @Binding var mode: Mode
    
    var body: some View {
        List(Mode.allCases, id: \.self, selection: $mode) { item in
            Label(item.rawValue, systemImage: icon(for: item))
                .tag(item)
        }
        .navigationTitle("Select Mode")
        .listStyle(.sidebar)
    }
    
    private func icon(for mode: Mode) -> String {
        switch mode {
        case .backtest: return "clock.arrow.circlepath"
        case .liveTrade: return "chart.line.uptrend.xyaxis"
        }
    }
}
