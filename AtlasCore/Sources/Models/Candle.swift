//
//  Candle.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public struct Candle: Codable {
    let time: Int
    var open: Double
    var high: Double
    var low: Double
    var close: Double
}


public struct Chart {
    //use index to get indicator for each candle
    let name: String
    let candles: [Candle]
    let indicators: [String: [Double]]
}
