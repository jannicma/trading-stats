//
//  Candle.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public struct Candle: Codable {
    public let time: Int
    public var open: Double
    public var high: Double
    public var low: Double
    public var close: Double
}


public struct Chart {
    //use index to get indicator for each candle
    public let name: String
    public let candles: [Candle]
    public let indicators: [String: [Double]]
}
