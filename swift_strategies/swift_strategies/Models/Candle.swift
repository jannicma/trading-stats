//
//  Candle.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

struct Candle: Codable {
    let time: Int
    let open: Double
    let high: Double
    let low: Double
    let close: Double
}


struct IndicatorCandle: Codable {
    let ohlc: Candle
    var sma200: Double = 0.0
    var sma20: Double = 0.0
    var sma5: Double = 0.0
    var atr: Double = 0.0
    var atrPercentage: Double = 0.0
}
