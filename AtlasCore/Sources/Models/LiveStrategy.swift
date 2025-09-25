//
//  LiveStrategy.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 25.09.2025.
//
import SwiftUI
import Foundation

public struct LiveStrategy: Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var profit: Double // running P&L in account currency
    public var startedAt: Date
    public var symbol: String
    public var colorA: Color
    public var colorB: Color

    public init(id: UUID = UUID(), name: String, profit: Double, startedAt: Date, symbol: String, colorA: Color, colorB: Color) {
        self.id = id
        self.name = name
        self.profit = profit
        self.startedAt = startedAt
        self.symbol = symbol
        self.colorA = colorA
        self.colorB = colorB
    }
}
