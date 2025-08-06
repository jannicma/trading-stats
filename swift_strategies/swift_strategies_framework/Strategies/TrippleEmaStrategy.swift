//
//  TrippleEmaStrategy.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

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

    
    func backtest(chart: Chart, paramSet: ParameterSet) -> EvaluationModel {
        let tpMult = paramSet.parameters.filter{$0.name == "tpAtrMult"}.first!.value
        let slMult = paramSet.parameters.filter{$0.name == "slAtrMult"}.first!.value
        
        var allTrades: [SimulatedTrade] = []
        var trade: SimulatedTrade?

        for i in 1..<chart.candles.count-1 {
            let currCandle = chart.candles[i]
            
            if !isCorrectOrder(index: i-1, indicators: chart.indicators) && isCorrectOrder(index: i, indicators: chart.indicators)  && trade == nil {
                //this is the entry logic. All EMA/SMA crossed into the right order.
                let atr = chart.indicators["ATR14"]![i]
                trade = createTrade(currCandle, atr: atr, tpMult: tpMult, slMult: slMult)
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
    
    
    private func checkForExit(trade: inout SimulatedTrade, candle: Candle) {
        let high = candle.high
        let low = candle.low
        
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
    
    
    private func createTrade(_ candle: Candle, atr: Double, tpMult: Double, slMult: Double) -> SimulatedTrade {
        var trade: SimulatedTrade
        assert(atr > 0)
        
        if isBull(candle) {
            let entry = candle.close
            let slPrice = entry - (slMult * atr)
            let tpPrice = entry + (tpMult * atr)
            trade = SimulatedTrade(entryPrice: entry, tpPrice: tpPrice, slPrice: slPrice, atrAtEntry: atr)
        } else {
            let entry = candle.close
            let slPrice = entry + (slMult * atr)
            let tpPrice = entry - (tpMult * atr)
            trade = SimulatedTrade(entryPrice: entry, tpPrice: tpPrice, slPrice: slPrice, atrAtEntry: atr)
        }

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
