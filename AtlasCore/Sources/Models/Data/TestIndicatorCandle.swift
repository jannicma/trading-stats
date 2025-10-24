//
//  TestIndicatorCandle.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public struct TestIndicatorCandle: Codable {
    public init(time: Int, open: Double, high: Double, low: Double, close: Double, sma5: Double, sma7: Double, atr5: Double, atr7: Double, rsi5: Double, rsi7: Double, stoch5: Double, stoch7: Double) {
        self.time = time
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.sma5 = sma5
        self.sma7 = sma7
        self.atr5 = atr5
        self.atr7 = atr7
        self.rsi5 = rsi5
        self.rsi7 = rsi7
        self.stoch5 = stoch5
        self.stoch7 = stoch7
    }
    
    let time: Int
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var sma5: Double
    var sma7: Double
    var atr5: Double
    var atr7: Double
    var rsi5: Double
    var rsi7: Double
    var stoch5: Double
    var stoch7: Double
}
