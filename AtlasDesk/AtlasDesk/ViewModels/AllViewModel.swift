//
//  AllViewModel.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 23.08.2025.
//
import SwiftUI

@Observable
final class DashboardModel {
    var mode: Mode = .backtest
    var strategies: [Strategy] = [
        Strategy(
            name: "Strat A",
            metrics: [
                Metric(label: "abc", value: 3),
                Metric(label: "xyz", value: 5),
                Metric(label: "xxx", value: 2)
            ],
            color: .blue
        ),
        Strategy(
            name: "Strat B",
            metrics: [
                Metric(label: "abc", value: 7),
                Metric(label: "xyz", value: 2),
                Metric(label: "xxx", value: 5)
            ],
            color: .green
        ),
        Strategy(
            name: "Strat C",
            metrics: [
                Metric(label: "abc", value: 4),
                Metric(label: "xyz", value: 6),
                Metric(label: "xxx", value: 3)
            ],
            color: .orange
        )
    ]
}
