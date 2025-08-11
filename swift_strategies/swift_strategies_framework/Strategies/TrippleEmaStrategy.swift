//
//  TrippleEmaStrategy.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//
import Foundation

struct TrippleEmaStrategy: Strategy {
    public func getRequiredParameters() -> [ParameterRequirements] {
        return [
            ParameterRequirements(name: "tpAtrMult", minValue: 2, maxValue: 10, step: 0.5),
            ParameterRequirements(name: "slAtrMult", minValue: 1, maxValue: 7, step: 0.5)
        ]
    }
    
    public func getRequiredIndicators() -> [Indicator] {
        return [
            Indicator.sma(period: 5),
            Indicator.sma(period: 20),
            Indicator.sma(period: 200),
            Indicator.atr(length: 14)
        ]
    }

    
    func backtest(chart: Chart, paramSet: ParameterSet) -> [SimulatedTrade] {
        let tpMult = paramSet.parameters.filter{$0.name == "tpAtrMult"}.first!.value
        let slMult = paramSet.parameters.filter{$0.name == "slAtrMult"}.first!.value
        let tradeManager = TradeManager()
        
        var trade: UUID?

        for i in 1..<chart.candles.count-1 {
            let currCandle = chart.candles[i]
            
            if !isCorrectOrder(index: i-1, indicators: chart.indicators) && isCorrectOrder(index: i, indicators: chart.indicators)  && trade == nil {
                //this is the entry logic. All EMA/SMA crossed into the right order.
                let atr = chart.indicators["ATR14"]![i]
                trade = createTrade(with: tradeManager, candle: currCandle, atr: atr, tpMult: tpMult, slMult: slMult)
            }
            
            if trade != nil {
                //exit check!
                let isExit = checkForExit(tradeId: trade!, candle: currCandle, manager: tradeManager)
                if isExit { trade = nil }
            }
        }
        
        return tradeManager.finishBacktest()
    }
    
    
    private func checkForExit(tradeId: UUID, candle: Candle, manager: TradeManager) -> Bool {
        let high = candle.high
        let low = candle.low
        let trade = manager.get(tradeId)
        
        let isLong = trade.entryPrice > trade.slPrice
        
        var isExit = false
        var closePrice = 0.0
        
        //calculate exit prices (when long, low below SL price, ...)
        if isLong{
            if low <= trade.slPrice{
                closePrice = trade.slPrice
                isExit = true
            }
            if high >= trade.tpPrice{
                closePrice = trade.tpPrice
                isExit = true
            }
        }
        else{
            if high >= trade.slPrice{
                closePrice = trade.slPrice
                isExit = true
            }
            if low <= trade.tpPrice{
                closePrice = trade.tpPrice
                isExit = true
            }
        }
        
        if isExit{
            _ = manager.exit(tradeId, close: closePrice)
        }
        
        return isExit
    }
    
    
    private func createTrade(with manager: TradeManager, candle: Candle, atr: Double, tpMult: Double, slMult: Double) -> UUID {
        var trade: UUID
        assert(atr > 0)
        var entry, slPrice, tpPrice: Double
        entry = candle.close

        if isBull(candle) {
            slPrice = entry - (slMult * atr)
            tpPrice = entry + (tpMult * atr)
        } else {
            slPrice = entry + (slMult * atr)
            tpPrice = entry - (tpMult * atr)
        }
        let volume = manager.computeVolume(slDistance: abs(entry - slPrice))
        trade = manager.enter(time: candle.time, open: entry, volume: volume, sl: slPrice, tp: tpPrice, atr: atr)

        return trade
    }
    
    
    private func isBull(_ candle: Candle) -> Bool {
        return candle.close > candle.open
    }
    
    
    private func isCorrectOrder(index: Int, indicators: [String: [Double]]) -> Bool {
        var correctOrder: Bool = false
        let sma5 = indicators["SMA5"]![index]
        let sma20 = indicators["SMA20"]![index]
        let sma200 = indicators["SMA200"]![index]
        
        if sma5 > sma20 && sma20 > sma200 {
            correctOrder = true
        }
        
        if sma200 > sma20 && sma20 > sma5 {
            correctOrder = true
        }
        
        return correctOrder
    }
}
