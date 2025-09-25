//
//  LiveStrategyGrid.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 25.09.2025.
//
import SwiftUI
import AtlasCore

struct LiveStrategyGrid: View {
    init(strategies: [LiveStrategy], onTap: @escaping (LiveStrategy) -> Void, onOpenLog: @escaping (LiveStrategy) -> Void, onPause: @escaping (LiveStrategy) -> Void, onStop: @escaping (LiveStrategy) -> Void) {
        self.strategies = strategies
        self.onTap = onTap
        self.onOpenLog = onOpenLog
        self.onPause = onPause
        self.onStop = onStop
    }
    
    let strategies: [LiveStrategy]
    var onTap: (LiveStrategy) -> Void
    var onOpenLog: (LiveStrategy) -> Void
    var onPause: (LiveStrategy) -> Void
    var onStop: (LiveStrategy) -> Void

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
