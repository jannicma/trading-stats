//
//  TradeManager.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 07.08.2025.
//
import Foundation

public class TradeManager {
    private var trades: [UUID: SimulatedTrade] = [:]
    
    public func enter(time: Int, open: Double, volume: Double,
                      sl: Double, tp: Double, atr: Double) -> UUID {
        let tradeId = UUID()
        let trade = SimulatedTrade(timestamp: time, entryPrice: open, volume: volume, tpPrice: tp, slPrice: sl, atrAtEntry: atr)
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
    
    public func get(_ id: UUID) -> SimulatedTrade {
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
    
    public func finishBacktest() -> [SimulatedTrade] {
        return Array(trades.values).filter{$0.exitPrice != nil}
    }
}
