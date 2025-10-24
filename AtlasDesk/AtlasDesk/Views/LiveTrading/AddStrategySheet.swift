//
//  AddStrategySheet.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 25.09.2025.
//
import SwiftUI
import AtlasCore
import AtlasPlaybook

struct AddStrategySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: LiveTradeDashboardViewModel

    @State private var template: StrategyType = .trippleSmaStrategy
    @State private var symbol: String = "BTC-PERPETUAL"

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
                Task{
                    await vm.addStrategy(template: template,
                                         symbol: symbol.trimmingCharacters(in: .whitespaces))
                }
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .disabled(false)
        }
        .padding(16)
    }

    private var form: some View {
        Form {
            Picker("Strategy", selection: $template) {
                ForEach(StrategyType.allCases) { t in
                    Text(t.type.self.name).tag(t)
                }
            }

        }
        .padding(16)
    }
}
