//
//  TradeManager.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 23.08.2025.
//

import Foundation
import AtlasCore

public class TradeManager {
    public init() {}
    
    private var trades: [UUID: Trade] = [:]
    private var startBalance: Double = 100000.0
    private var riskPerTrade: Double = 0.015
    
    public func enter(time: Int, open: Double, volume: Double,
                      sl: Double, tp: Double, atr: Double) -> UUID {
        let tradeId = UUID()
        let trade = Trade(timestamp: time, entryPrice: open, volume: volume, tpPrice: tp, slPrice: sl, atrAtEntry: atr)
        trades[tradeId] = trade
        return tradeId
    }
    
    public func exit(_ id: UUID, close: Double) -> Double {
        trades[id]!.exitPrice = close
        var priceMove = close - trades[id]!.entryPrice
        priceMove = priceMove * (trades[id]!.isLong ? 1 : -1)
        let pnl = priceMove * trades[id]!.volume
        
        return pnl
    }
    
    public func get(_ id: UUID) -> Trade {
        return trades[id]!
    }
    
    public func getOpenTrades() -> [UUID] {
        var openTrades: [UUID] = []
        for (tradeId, trade) in trades {
            if trade.exitPrice == nil {
                openTrades.append(tradeId)
            }
        }
        return openTrades
    }
    
    public func finishBacktest() -> [Trade] {
        return Array(trades.values).filter{$0.exitPrice != nil}
    }
    
    public func computeVolume(slDistance: Double) -> Double {
        let risk = startBalance * riskPerTrade
        let positionSize = risk / slDistance
        return positionSize
    }
}
