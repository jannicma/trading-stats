//
//  StrategyDetail.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 24.08.2025.
//
import SwiftUI
import Charts
import AtlasCore

// MARK: - Models & ViewModel

struct BacktestResult: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let timeframe: String
    let asset: String
    let sharpe: Double
    let drawdown: Double // 0.23 = 23%
    let expectancy: Double
    let winRate: Double  // 0.55 = 55%
    let trades: Int
}


extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

struct StrategyDetail: View {
    @StateObject private var viewModel: StrategyDetailViewModel
    @State private var selection: Set<BacktestResult.ID> = []

    init(evaluation: StrategyEvaluations) {
        _viewModel = StateObject(wrappedValue: StrategyDetailViewModel(evaluation: evaluation))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title of the selected Strategy
            Text(viewModel.evaluation.strategyName)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            // Top: Table of backtests
            Table(viewModel.results, selection: $selection) {
                TableColumn("Timeframe") { r in Text(r.timeframe) }
                TableColumn("Asset") { r in Text(r.asset) }
                TableColumn("Sharpe") { r in Text(format(r.sharpe)) }
                TableColumn("DD") { r in Text(percent(r.drawdown)) }
                TableColumn("Expectancy") { r in Text(format(r.expectancy)) }
                TableColumn("Win %") { r in Text(percent(r.winRate)) }
                TableColumn("Trades") { r in Text("\(r.trades)") }
            }
            .onChange(of: selection) { _, newValue in
                if let id = newValue.first, let found = viewModel.results.first(where: { $0.id == id }) {
                    viewModel.selected = found
                } else {
                    viewModel.selected = viewModel.results.first
                }
            }
            .frame(minHeight: 220)

            Divider()

            // Bottom: Detail area with info box (left) and equity curve (right)
            if let selected = viewModel.selected {
                HStack(alignment: .top, spacing: 24) {
                    // Info box
                    VStack(alignment: .leading, spacing: 8) {
                        infoRow(title: "Asset", value: selected.asset)
                        infoRow(title: "Timeframe", value: selected.timeframe)
                        infoRow(title: "Sharpe", value: format(selected.sharpe))
                        infoRow(title: "Drawdown", value: percent(selected.drawdown))
                        infoRow(title: "Expectancy", value: format(selected.expectancy))
                        infoRow(title: "Win %", value: percent(selected.winRate))
                        infoRow(title: "Trades", value: String(selected.trades))
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.background)
                            .shadow(radius: 1, y: 1)
                    )

                    // Equity chart box
                    VStack(alignment: .leading) {
                        Chart(viewModel.equity(for: selected)) { item in
                            LineMark(
                                x: .value("Step", item.step),
                                y: .value("Equity", item.equity)
                            )
                        }
                        .chartYAxisLabel("Equity")
                        .frame(height: 240)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.background)
                            .shadow(radius: 1, y: 1)
                    )
                }
            } else {
                Text("Select a backtest above to see details")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .onAppear {
            if viewModel.selected == nil { viewModel.selected = viewModel.results.first }
            if let sel = viewModel.selected?.id { selection = [sel] }
        }
    }

    // MARK: - Helpers
    @ViewBuilder
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title + ":")
                .foregroundStyle(.secondary)
            Text(value)
                .monospacedDigit()
        }
    }

    private func format(_ value: Double) -> String {
        if value == floor(value) { return String(Int(value)) }
        return String(format: "%.2f", value)
    }

    private func percent(_ value: Double) -> String {
        return String(format: "%.1f%%", value * 100)
    }
}
