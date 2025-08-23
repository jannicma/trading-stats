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
                StrategyGrid(strategies: model.strategies)
            case .liveTrade:
                LiveTradePlaceholder()
            }
        }
    }
}


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


struct StrategyGrid: View {
    let strategies: [Strategy]
    @State private var selected: Strategy?
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(strategies) { strategy in
                    StrategyCard(strategy: strategy)
                        .onTapGesture { selected = strategy }
                }
            }
            .padding(20)
        }
        .navigationTitle("Backtest Strategies")
        .sheet(item: $selected) { item in
            StrategyDetail(strategy: item)
                .presentationDetents([.fraction(0.45), .large])
                .presentationDragIndicator(.visible)
        }
    }
}


struct StrategyCard: View {
    let strategy: Strategy
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(strategy.color.opacity(0.15))
                Text(strategy.name)
                    .font(.headline)
                    .padding(.vertical, 26)
            }
            .frame(height: 110)
            
            HStack(spacing: 12) {
                ForEach(strategy.metrics) { m in
                    VStack {
                        Text(m.label.uppercased())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(format(m.value))
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.background)
                .shadow(radius: 2, y: 1)
        )
    }
    
    private func format(_ value: Double) -> String {
        if value == floor(value) { return String(Int(value)) }
        return String(format: "%.2f", value)
    }
}


struct StrategyDetail: View {
    let strategy: Strategy
    
    var equity: [EquityPoint] {
        var points: [EquityPoint] = []
        var last = 100.0
        for i in 0..<20 {
            last += Double.random(in: -3...7)
            points.append(.init(step: i, equity: max(80, last)))
        }
        return points
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Capsule()
                .fill(.secondary.opacity(0.4))
                .frame(width: 44, height: 5)
                .frame(maxWidth: .infinity)
                .opacity(0) // Drag indicator is provided by the sheet
            
            Text("\(strategy.name) details")
                .font(.title2)
                .bold()
            
            HStack(alignment: .top, spacing: 24) {
                // Metrics list
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(strategy.metrics) { m in
                        HStack {
                            Text("\(m.label):")
                                .foregroundStyle(.secondary)
                            Text(format(m.value))
                                .monospacedDigit()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Equity chart
                Chart(equity) { item in
                    LineMark(
                        x: .value("Step", item.step),
                        y: .value("Equity", item.equity)
                    )
                }
                .chartYAxisLabel("Equity")
                .frame(height: 220)
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func format(_ value: Double) -> String {
        if value == floor(value) { return String(Int(value)) }
        return String(format: "%.2f", value)
    }
}

struct LiveTradePlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
            Text("Live Trade")
                .font(.title2)
            Text("Hook your live trading view in here.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



#Preview {
    ContentView()
}
