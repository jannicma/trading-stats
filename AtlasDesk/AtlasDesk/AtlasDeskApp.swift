//
//  AtlasDeskApp.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 22.08.2025.
//

import SwiftUI
import AtlasCore

@main
struct AtlasDeskApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        WindowGroup(for: StrategyEvaluations.self) { $evaluation in
            if let evaluation {
                StrategyDetail(evaluation: evaluation)
            } else {
                Text("No strategy selected")
            }
        }
        .defaultSize(width: 820, height: 620)
        .windowResizability(.contentSize)
    }
}
