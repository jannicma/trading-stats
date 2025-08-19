//
//  TestIndicatorChart.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 16.08.2025.
//

public struct TestIndicatorCandle: Codable {
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
