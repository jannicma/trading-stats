//
//  LiveStrategyGrid.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 25.09.2025.
//
import SwiftUI

struct LiveStrategyGrid: View {
    init(strategies: [StrategyModel], onTap: @escaping (StrategyModel) -> Void, onOpenLog: @escaping (StrategyModel) -> Void, onPause: @escaping (StrategyModel) -> Void, onStop: @escaping (StrategyModel) -> Void) {
        self.strategies = strategies
        self.onTap = onTap
        self.onOpenLog = onOpenLog
        self.onPause = onPause
        self.onStop = onStop
    }
    
    let strategies: [StrategyModel]
    var onTap: (StrategyModel) -> Void
    var onOpenLog: (StrategyModel) -> Void
    var onPause: (StrategyModel) -> Void
    var onStop: (StrategyModel) -> Void

    private var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 240, maximum: 320), spacing: 12, alignment: .top)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(strategies) { strategy in
                    StrategyTile(strategy: strategy, onTap: onTap)
                        .contextMenu {
                            Button("Open Console Log") { onOpenLog(strategy) }
                            Button("Pause") { onPause(strategy) }
                            Button("Stop") { onStop(strategy) }
                        }
                }
            }
            .padding(12)
        }
    }
}
