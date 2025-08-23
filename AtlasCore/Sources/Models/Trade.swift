//
//  Trade.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public struct Trade {
    public var timestamp: Int
    public var entryPrice: Double
    public var volume: Double
    public var tpPrice: Double?
    public var slPrice: Double
    public var exitPrice: Double?
    public var atrAtEntry: Double
    
    public init(
        timestamp: Int,
        entryPrice: Double,
        volume: Double,
        tpPrice: Double? = nil,
        slPrice: Double,
        exitPrice: Double? = nil,
        atrAtEntry: Double
    ) {
        self.timestamp = timestamp
        self.entryPrice = entryPrice
        self.volume = volume
        self.tpPrice = tpPrice
        self.slPrice = slPrice
        self.exitPrice = exitPrice
        self.atrAtEntry = atrAtEntry
    }

    public var isLong: Bool { entryPrice > slPrice }
}
