//
//  trippleEmaStrategy.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

class TrippleEmaStrategy: Strategy {
    var tpAtrMultiplier: Double = 6
    var slAtrMultiplier: Double = 3
    
    func backtest(chart: String, tpMult: Double, slMult: Double) -> EvaluationModel {
        tpAtrMultiplier = tpMult
        slAtrMultiplier = slMult
        
        let rawCandles = CsvController.getCandles(path: chart)
        let IndicatorController = IndicatorController()
        let candles = IndicatorController.addIndicators(candles: rawCandles, "sma200", "sma20", "sma5", "atr")
        var allTrades: [SimulatedTrade] = []
        var trade: SimulatedTrade?

        for i in 1..<candles.count-1 {
            let currCandle = candles[i]
            let prevCandle = candles[i-1]
            
            if !isCorrectOrder(prevCandle) && isCorrectOrder(currCandle)  && trade == nil {
                //this is the entry logic. All EMA/SMA crossed into the right order.
                trade = createTrade(currCandle)
            }
            
            if trade != nil {
                //exit check!
                checkForExit(trade: &trade!, candle: currCandle)
                
                if trade?.exitPrice != nil {
                    // exit condition (SL, TP) got hit. 
                    allTrades.append(trade!)
                    trade = nil
                }
            }
        }
        
        let evaluationController = EvaluationController()
        let evaluation = evaluationController.evaluateTrades(simulatedTrades: allTrades)
        return evaluation
    }
    
    
    private func checkForExit(trade: inout SimulatedTrade, candle: IndicatorCandle) {
        let high = candle.ohlc.high
        let low = candle.ohlc.low
        
        let isLong = trade.entryPrice > trade.slPrice
        
        //calculate exit prices (when long, low below SL price, ...)
        if isLong{
            if low <= trade.slPrice{
                trade.exitPrice = trade.slPrice
            }
            if high >= trade.tpPrice{
                trade.exitPrice = trade.tpPrice
            }
        }
        else{
            if high >= trade.slPrice{
                trade.exitPrice = trade.slPrice
            }
            if low <= trade.tpPrice{
                trade.exitPrice = trade.tpPrice
            }
        }
    }
    
    
    private func createTrade(_ candle: IndicatorCandle) -> SimulatedTrade {
        var trade: SimulatedTrade
        assert(candle.atr > 0)
        
        if isBull(candle) {
            let entry = candle.ohlc.close
            let slPrice = entry - (slAtrMultiplier * candle.atr)
            let tpPrice = entry + (tpAtrMultiplier * candle.atr)
            trade = SimulatedTrade(entryPrice: entry, tpPrice: tpPrice, slPrice: slPrice)
        } else {
            let entry = candle.ohlc.close
            let slPrice = entry + (slAtrMultiplier * candle.atr)
            let tpPrice = entry - (tpAtrMultiplier * candle.atr)
            trade = SimulatedTrade(entryPrice: entry, tpPrice: tpPrice, slPrice: slPrice)
        }

        return trade
    }
    
    
    private func isBull(_ candle: IndicatorCandle) -> Bool {
        return candle.ohlc.close > candle.sma5
    }
    
    
    private func isCorrectOrder(_ candle: IndicatorCandle) -> Bool {
        var correctOrder: Bool = false
        
        if candle.sma5 > candle.sma20 && candle.sma20 > candle.sma200 {
            correctOrder = true
        }
        
        if candle.sma200 > candle.sma20 && candle.sma20 > candle.sma5 {
            correctOrder = true
        }
        
        return correctOrder
    }
}
