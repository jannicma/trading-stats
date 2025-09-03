//
//  StrategyCard.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 24.08.2025.
//
import SwiftUI
import AtlasCore

struct StrategyCard: View {
    let strategy: any Strategy
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.blue.opacity(0.15))
                Text(strategy.name)
                    .font(.headline)
                    .padding(.vertical, 26)
            }
            .frame(height: 110)
            
            HStack(spacing: 12) {
            /*    ForEach(strategy.metrics) { m in
                    VStack {
                        Text(m.label.uppercased())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(format(m.value))
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                }   */
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
