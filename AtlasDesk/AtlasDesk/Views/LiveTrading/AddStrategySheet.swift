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
    
    @State private var selectedStrategy: StrategyType = .trippleSmaStrategy
    @State private var symbol: String = "BTC-PERPETUAL"
    @State private var timeframe: Int = 1
    @State private var parameterSet: ParameterSet = .init(parameters: [])
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            form
        }
        .frame(minWidth: 420, minHeight: 360)
        .onChange(of: selectedStrategy) { _, newVal in
            parameterSet = vm.getStrategyParameterDefaults(stratType: newVal)
        }
        .task{
            parameterSet = vm.getStrategyParameterDefaults(stratType: selectedStrategy)
        }
    }
    
    private var header: some View {
        HStack {
            Text("Add Strategy").font(.title2).bold()
            Spacer()
            Button("Cancel") { dismiss() }
            Button("Add") {
                Task{
                    await vm.addStrategy(strategy: selectedStrategy, params: parameterSet,
                                         symbol: symbol.trimmingCharacters(in: .whitespaces), timeframe: timeframe)
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
            Picker("Strategy", selection: $selectedStrategy) {
                ForEach(StrategyType.allCases) { t in
                    Text(t.type.self.name).tag(t)
                }
            }
            
            parameterForm
            
            TextField("Symbol", text: $symbol)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            
            TextField("Timeframe", value: $timeframe, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
        }
        .padding(16)
    }
    
    private var parameterForm: some View {
        ForEach($parameterSet.parameters, id: \.name) { $parameter in
            TextField(parameter.name, value: $parameter.value, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
        }
    }
}

