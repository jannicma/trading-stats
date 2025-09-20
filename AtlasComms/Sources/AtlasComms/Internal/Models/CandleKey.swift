//
//  CandleKey.swift
//  AtlasComms
//
//  Created by Jannic Marcon on 19.09.2025.
//

public struct CandleKey: Hashable, Sendable {
    public let symbol: String
    public let resolution: Int
    public var channel: String { "chart.trades.\(symbol).\(resolution)" }
    public var id: String { "\(symbol)@\(resolution)" }
}
