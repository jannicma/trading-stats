//
//  AllModels.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 23.08.2025.
//
import Foundation
import Charts
import SwiftUI


struct Metric: Identifiable, Hashable, Codable {
    let id: UUID
    let label: String
    let value: Double
}

struct EquityPoint: Identifiable {
    let id = UUID()
    let step: Int
    let equity: Double
}
