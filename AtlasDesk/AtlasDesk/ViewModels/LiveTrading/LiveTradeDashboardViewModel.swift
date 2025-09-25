//
//  LiveTradeDashboardViewModel.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 25.09.2025.
//
import Foundation
import SwiftUI

final class LiveTradeDashboardViewModel: ObservableObject {
    @Published var strategies: [StrategyModel] = []

    init() { seedMock() }

    // Quick-add used earlier; keeping for convenience
    func addStrategy() {
        let colors: [(Color, Color)] = [(.blue, .purple), (.pink, .orange), (.green, .teal), (.mint, .cyan), (.indigo, .blue), (.yellow, .orange)]
        let pick = colors.randomElement() ?? (.blue, .purple)
        let new = StrategyModel(
            name: randomName(),
            profit: Double.random(in: -500...2500).rounded(.toNearestOrAwayFromZero),
            startedAt: .now.addingTimeInterval(-Double.random(in: 300...60*60*36)),
            symbol: randomSymbol(),
            colorA: pick.0,
            colorB: pick.1
        )
        strategies.insert(new, at: 0)
        print("[VM] Add strategy tapped -> created: \(new.name) \(new.symbol) id=\(new.id)")
    }

    func addStrategy(template: StrategyTemplate, symbol: String?, colorA: Color?, colorB: Color?) {
        let name = template.rawValue
        let sym = symbol?.isEmpty == false ? symbol! : randomSymbol()

        // default colors per template for consistency
        let defaults: (Color, Color) = {
            switch template {
            case .momentum: return (.blue, .purple)
            case .breakout: return (.pink, .orange)
            case .meanReversion: return (.indigo, .blue)
            case .gridBot: return (.green, .teal)
            case .arbScout: return (.mint, .cyan)
            }
        }()

        let cA = colorA ?? defaults.0
        let cB = colorB ?? defaults.1

        let new = StrategyModel(
            name: name,
            profit: Double.random(in: -200...1200),
            startedAt: .now.addingTimeInterval(-Double.random(in: 120...60*60*12)),
            symbol: sym,
            colorA: cA,
            colorB: cB
        )
        strategies.insert(new, at: 0)
        print("[VM] Added via sheet: \(new.name) sym=\(new.symbol) colors=(\(cA), \(cB)) id=\(new.id)")
    }

    // Tile & menu actions
    func tapStrategy(_ strategy: StrategyModel) { print("[VM] Tile tapped -> \(strategy.name) id=\(strategy.id)") }
    func openLog(for strategy: StrategyModel) { print("[VM] Open Console Log for: \(strategy.name) id=\(strategy.id)") }
    func pause(_ strategy: StrategyModel) { print("[VM] Pause requested for: \(strategy.name)") }
    func stop(_ strategy: StrategyModel) { print("[VM] Stop requested for: \(strategy.name)") }

    // Mock
    private func seedMock() {
        strategies = [
            StrategyModel(name: "Mean Reversion", profit: 1234.56, startedAt: .now.addingTimeInterval(TimeInterval(-60*60*7 - 60*22)), symbol: "BTC-PERP", colorA: .blue, colorB: .purple),
            StrategyModel(name: "Breakout", profit: -245.12, startedAt: .now.addingTimeInterval(TimeInterval(-60*60*2 - 60*5)), symbol: "ETH-PERP", colorA: .pink, colorB: .orange),
            StrategyModel(name: "Grid Bot", profit: 89.40, startedAt: .now.addingTimeInterval(TimeInterval(-60*60*30)), symbol: "SOL-PERP", colorA: .green, colorB: .teal),
            StrategyModel(name: "Arb Scout", profit: 512.03, startedAt: .now.addingTimeInterval(TimeInterval(-60*12)), symbol: "BNB-PERP", colorA: .mint, colorB: .cyan)
        ]
    }

    private func randomName() -> String {
        ["Momentum", "Breakout", "Mean Reversion", "Grid Bot", "Scalper", "Arb Scout", "Carry", "Vol Hunter"].randomElement()!
    }

    private func randomSymbol() -> String {
        ["BTC-PERP", "ETH-PERP", "SOL-PERP", "BNB-PERP", "XRP-PERP", "DOGE-PERP"].randomElement()!
    }
}
