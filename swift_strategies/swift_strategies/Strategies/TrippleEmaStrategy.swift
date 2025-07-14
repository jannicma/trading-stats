//
//  trippleEmaStrategy.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

struct TrippleEmaStrategy: Strategy {
    func backtest(chart: [IndicatorCandle], tpMult: Double, slMult: Double) -> EvaluationModel {
        var allTrades: [SimulatedTrade] = []
        var trade: SimulatedTrade?

        for i in 1..<chart.count-1 {
            let currCandle = chart[i]
            let prevCandle = chart[i-1]
            
            if !isCorrectOrder(prevCandle) && isCorrectOrder(currCandle)  && trade == nil {
                //this is the entry logic. All EMA/SMA crossed into the right order.
                trade = createTrade(currCandle, tpMult: tpMult, slMult: slMult)
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
        let evaluation = evaluationController.evaluateTrades(simulatedTrades: allTrades, risk: slMult, reward: tpMult)
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
    
    
    private func createTrade(_ candle: IndicatorCandle, tpMult: Double, slMult: Double) -> SimulatedTrade {
        var trade: SimulatedTrade
        assert(candle.atr > 0)
        
        if isBull(candle) {
            let entry = candle.ohlc.close
            let slPrice = entry - (slMult * candle.atr)
            let tpPrice = entry + (tpMult * candle.atr)
            trade = SimulatedTrade(entryPrice: entry, tpPrice: tpPrice, slPrice: slPrice, atrAtEntry: candle.atr)
        } else {
            let entry = candle.ohlc.close
            let slPrice = entry + (slMult * candle.atr)
            let tpPrice = entry - (tpMult * candle.atr)
            trade = SimulatedTrade(entryPrice: entry, tpPrice: tpPrice, slPrice: slPrice, atrAtEntry: candle.atr)
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
