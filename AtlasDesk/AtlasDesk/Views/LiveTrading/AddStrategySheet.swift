//
//  AddStrategySheet.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 25.09.2025.
//
import SwiftUI

enum StrategyTemplate: String, CaseIterable, Identifiable {
    case momentum = "Momentum"
    case breakout = "Breakout"
    case meanReversion = "Mean Reversion"
    case gridBot = "Grid Bot"
    case arbScout = "Arb Scout"

    var id: String { rawValue }
    /// Simple rule: some templates customize colors, others customize symbol (not both)
    var needsColors: Bool {
        switch self {
        case .momentum, .gridBot: return true
        default: return false
        }
    }
    var needsSymbol: Bool { !needsColors }
}

struct AddStrategySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: LiveTradeDashboardViewModel

    @State private var template: StrategyTemplate = .momentum
    @State private var symbol: String = "BTC-PERP"
    @State private var colorA: Color = .blue
    @State private var colorB: Color = .purple

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            form
        }
        .frame(minWidth: 420, minHeight: 360)
    }

    private var header: some View {
        HStack {
            Text("Add Strategy").font(.title2).bold()
            Spacer()
            Button("Cancel") { dismiss() }
            Button("Add") {
                vm.addStrategy(template: template,
                                symbol: template.needsSymbol ? symbol.trimmingCharacters(in: .whitespaces) : nil,
                                colorA: template.needsColors ? colorA : nil,
                                colorB: template.needsColors ? colorB : nil)
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .disabled(template.needsSymbol && symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(16)
    }

    private var form: some View {
        Form {
            Picker("Strategy", selection: $template) {
                ForEach(StrategyTemplate.allCases) { t in
                    Text(t.rawValue).tag(t)
                }
            }

            if template.needsColors {
                ColorPicker("Primary Color (A)", selection: $colorA, supportsOpacity: false)
                ColorPicker("Secondary Color (B)", selection: $colorB, supportsOpacity: false)
            }

            if template.needsSymbol {
                TextField("Symbol", text: $symbol)
                    .textFieldStyle(.roundedBorder)
                    .help("e.g. BTC-PERP")
            }

            Section("Preview") {
                StrategyTile(strategy: StrategyModel(name: template.rawValue,
                                                     profit: 0,
                                                     startedAt: .now,
                                                     symbol: template.needsSymbol ? symbol : "BTC-PERP",
                                                     colorA: template.needsColors ? colorA : .blue,
                                                     colorB: template.needsColors ? colorB : .purple)) { _ in }
            }
        }
        .padding(16)
    }
}
