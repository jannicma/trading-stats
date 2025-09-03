//
//  ContentView.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 22.08.2025.
//

import SwiftUI
import Charts

struct ContentView: View {
    @State private var model = DashboardModel()
    
    var body: some View {
        NavigationSplitView {
            Sidebar(mode: $model.mode)
        } detail: {
            switch model.mode {
            case .backtest:
                StrategyGrid()
            case .liveTrade:
                LiveTradePlaceholder()
            }
        }
    }
}

#Preview {
    ContentView()
}
