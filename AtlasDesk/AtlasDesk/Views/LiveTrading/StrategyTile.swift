//
//  StrategyTile.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 25.09.2025.
//
import SwiftUI

struct StrategyTile: View {
    let strategy: StrategyModel
    let onTap: (StrategyModel) -> Void

    private var profitColor: Color { strategy.profit >= 0 ? .green : .red }

    var body: some View {
        Button(action: { onTap(strategy) }) {
            VStack(alignment: .leading, spacing: 10) {
                header
                profitPill
                runtime
                Sparkline().frame(height: 24).opacity(0.8)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.quaternary.opacity(0.25))
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.separator, lineWidth: 0.5)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(LinearGradient(colors: [strategy.colorA.opacity(0.5), strategy.colorB.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    .opacity(0.35)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(strategy.name)
    }

    private var header: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(colors: [strategy.colorA, strategy.colorB], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 28, height: 28)
                .overlay(Image(systemName: "chart.line.uptrend.xyaxis").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white))

            VStack(alignment: .leading, spacing: 2) {
                Text(strategy.name).font(.headline).lineLimit(1)
                Text(strategy.symbol).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }

    private var profitPill: some View {
        let color = profitColor
        return HStack(spacing: 6) {
            Image(systemName: strategy.profit >= 0 ? "arrow.up.right" : "arrow.down.right")
            Text(strategy.profit, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
        }
        .font(.subheadline.weight(.semibold))
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(color.opacity(0.12))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }

    private var runtime: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                Text(Self.relativeString(since: strategy.startedAt))
            }
            Spacer()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private static func relativeString(since date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 { return "Running \(h)h \(m)m" }
        return "Running \(m)m"
    }
}
