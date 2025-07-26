//
//  Candle.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

struct Candle: Codable {
    let time: Int
    var open: Double
    var high: Double
    var low: Double
    var close: Double
}


struct Chart {
    //use index to get indicator for each candle
    let name: String
    let candles: [Candle]
    let indicators: [String: [Double]]
}
