//
//  StrategyDetail.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 24.08.2025.
//
import SwiftUI
import Charts
import AtlasCore

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

struct StrategyDetail: View {
    @StateObject private var viewModel: StrategyDetailViewModel
    @State private var selection: Set<Evaluation.ID> = []

    init(evaluation: StrategyEvaluations) {
        _viewModel = StateObject(wrappedValue: StrategyDetailViewModel(evaluation: evaluation))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerBar
            resultsTable
            Divider()
            detailArea
            Spacer(minLength: 0)
        }
        .padding(20)
    }

    @ViewBuilder
    private var headerBar: some View {
        HStack {
            // Title of the selected Strategy
            Text(viewModel.evaluation.strategyName)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(String(viewModel.evaluation.evaluations.count))

            Button {
                Task {
                    await viewModel.runBacktest()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .imageScale(.large)
            }
            .keyboardShortcut("r", modifiers: [.command])
            .accessibilityLabel("Run backtest")
            .buttonStyle(.borderless)
            .help("Run backtest")
        }
    }

    @ViewBuilder
    private var resultsTable: some View {
        // Top: Table of backtests
        Table(viewModel.evaluation.evaluations, selection: $selection) {
            TableColumn("Symbol") { (r: Evaluation) in
                Text("\(r.symbol!)")
            }
            TableColumn("Timeframe") { (r: Evaluation) in
                Text("\(r.timeframe!)")
            }
            TableColumn("Trades") { (r: Evaluation) in
                Text("\(r.trades)")
            }
            TableColumn("Expectancy") { (r: Evaluation) in
                Text(String(format: "%.2f", r.expectancy))
            }
            TableColumn("R-Multiples") { (r: Evaluation) in
                Text(String(format: "%.2f", r.averageRMultiples))
            }
            TableColumn("Sharpe") { (r: Evaluation) in
                Text(String(format: "%.2f", r.sharpe))
            }
        }
        .onChange(of: selection) { _, newValue in
            if let id = newValue.first, let found = viewModel.evaluation.evaluations.first(where: { $0.id == id }) {
                viewModel.selected = found
            } else {
                viewModel.selected = viewModel.evaluation.evaluations.first
            }
        }
        .frame(minHeight: 220)
    }

    @ViewBuilder
    private var detailArea: some View {
        // Bottom: Detail area with info box (left) and equity curve (right)
        if let selected = viewModel.selected {
            backtestRunDetail(selected: selected)
        } else {
            Text("Select a backtest above to see details")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 200)
        }
    }

    // MARK: - Subviews
    @ViewBuilder
    private func backtestRunDetail(selected: Evaluation) -> some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                infoRow(title: "Symbol", value: selected.symbol ?? "")
                infoRow(title: "Timeframe", value: String(selected.timeframe ?? 0))
                infoRow(title: "Trades", value: String(selected.trades))
                infoRow(title: "Wins", value: String(selected.wins))
                infoRow(title: "Losses", value: String(selected.losses))
                infoRow(title: "Win Rate", value: percent(selected.winRate))
                infoRow(title: "Average R-Multiples", value: format(selected.averageRMultiples))
                infoRow(title: "Expectancy", value: format(selected.expectancy))
                infoRow(title: "Avg RRR", value: format(selected.avgRRR))
                infoRow(title: "Sharpe", value: format(selected.sharpe))
                infoRow(title: "Sortino", value: format(selected.sortino))
                infoRow(title: "Max Drawdown", value: format(selected.maxDrawdown))
                infoRow(title: "Calmar Ratio", value: format(selected.calmarRatio))
                infoRow(title: "Profit Factor", value: format(selected.profitFactor))
                infoRow(title: "Ulcer Index", value: format(selected.ulcerIndex))
                infoRow(title: "Recovery Factor", value: format(selected.recoveryFactor))
                infoRow(title: "Equity Variance", value: format(selected.equityVariance))
                infoRow(title: "Param Set", value: String(describing: selected.paramSet)) //TODO: nicely display all params
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
                Chart(selected.equityCurve) { item in
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
    }

    // MARK: - Row Helper
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



#Preview {
    StrategyDetail(evaluation: StrategyEvaluations(strategyName: "Test", evaluations: []))
}
