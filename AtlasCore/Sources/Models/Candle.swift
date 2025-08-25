//
//  Candle.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public struct Candle: Codable, Sendable {
    public init(time: Int, open: Double, high: Double, low: Double, close: Double) {
        self.time = time
        self.open = open
        self.high = high
        self.low = low
        self.close = close
    }
    
    public let time: Int
    public var open: Double
    public var high: Double
    public var low: Double
    public var close: Double
}


public struct Chart: Sendable {
    public init(name: String, timeframe: Int, candles: [Candle], indicators: [String : [Double]]) {
        self.name = name
        self.timeframe = timeframe
        self.candles = candles
        self.indicators = indicators
    }
    
    //use index to get indicator for each candle
    public let name: String
    public let timeframe: Int
    public let candles: [Candle]
    public var indicators: [String: [Double]]
}
