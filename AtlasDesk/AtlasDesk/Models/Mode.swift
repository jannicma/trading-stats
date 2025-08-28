//
//  Mode.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 28.08.2025.
//


enum Mode: String, CaseIterable, Identifiable {
    case backtest = "Backtest"
    case liveTrade = "Live Trade"
    var id: String { rawValue }
}
