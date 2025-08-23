//
//  AllModels.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 23.08.2025.
//
import Foundation
import Charts
import SwiftUI

enum Mode: String, CaseIterable, Identifiable {
    case backtest = "Backtest"
    case liveTrade = "Live Trade"
    var id: String { rawValue }
}

struct Strategy: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let metrics: [Metric]
    let color: Color
}

struct Metric: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: Double
}

struct EquityPoint: Identifiable {
    let id = UUID()
    let step: Int
    let equity: Double
}
