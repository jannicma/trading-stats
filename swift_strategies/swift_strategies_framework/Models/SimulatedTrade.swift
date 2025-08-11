//
//  SimulatedTrade.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

public struct SimulatedTrade {
    var timestamp: Int
    var entryPrice: Double
    var volume: Double
    var tpPrice: Double
    var slPrice: Double
    var exitPrice: Double?
    var atrAtEntry: Double
    
    var isLong: Bool {
        get {
            return entryPrice > slPrice
        }
    }
}
