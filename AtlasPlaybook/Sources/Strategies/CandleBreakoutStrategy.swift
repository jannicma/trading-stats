//
//  CandleBreakoutStrategy.swift
//  AtlasPlaybook
//
//  Created by Jannic Marcon on 06.09.2025.
//

import Foundation
import AtlasCore
import AtlasKit

public struct CandleBreakoutStrategy: Strategy {
    public var name: String = "Candle Breakout Strategy"
    public var id: UUID
    public init(id: UUID) {
        self.id = id
    }
    
    public func getRequiredParameters() -> [ParameterRequirements] {
        return [
            ParameterRequirements(name: "entryLookbackCandles", minValue: 1, maxValue: 5, step: 1),
            ParameterRequirements(name: "exitLookbackCandles", minValue: 1, maxValue: 5, step: 1)
        ]
    }
       
    var atrIndicator = Indicator.atr(length: 14)
    public func getRequiredIndicators() -> [Indicator] {
        return [atrIndicator]
    }
    
    
    public func backtest(chart: Chart, paramSet: ParameterSet) -> [Trade] {
        let tradeManager = TradeManager()
        let entryLookback = paramSet.parameters.filter{$0.name == "entryLookbackCandles"}.first!.value
        let exitLookback = paramSet.parameters.filter{$0.name == "exitLookbackCandles"}.first!.value

        var activeTrade: UUID? = nil
        for (idx, candle) in chart.candles.enumerated() {
            if idx < max(Int(entryLookback), Int(exitLookback)) { continue }
            let exitCompareCandle = chart.candles[idx - Int(exitLookback)]
            
            //validate exit
            if let tradeId = activeTrade {
                var exitPrice: Double?
                if tradeManager.get(tradeId).isLong {
                    if candle.low < exitCompareCandle.low { exitPrice = exitCompareCandle.low }
                } else {
                    if candle.high > exitCompareCandle.high { exitPrice = exitCompareCandle.high }
                }
                
                if let exitPrice {
                    _ = tradeManager.exit(tradeId, close: exitPrice)
                    activeTrade = nil
                }
            }
            
            //check entry
            if activeTrade == nil{
                let entryCompareCandle = chart.candles[idx - Int(entryLookback)]
                
                var entryPrice: Double?
                var startSL: Double?
                if candle.high > entryCompareCandle.high {
                    entryPrice = entryCompareCandle.high
                    startSL = exitCompareCandle.low
                } else if candle.low < entryCompareCandle.low {
                    entryPrice = entryCompareCandle.low
                    startSL = exitCompareCandle.high
                }
                // guard case where both are true
                
                if let entryPrice, let startSL {
                    let vol = tradeManager.computeVolume(slDistance: abs(entryPrice - startSL))
                    let currAtr = chart.indicators[atrIndicator.name]![idx]
                    activeTrade = tradeManager.enter(time: candle.time, open: entryPrice, volume: vol, sl: startSL, tp: 0.0, atr: currAtr)
                }
            }
            
        }
        
        return tradeManager.finishBacktest()
    }

}
