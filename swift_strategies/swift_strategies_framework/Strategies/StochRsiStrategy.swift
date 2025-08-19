//
//  StochRsiStrategy.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 13.08.2025.
//

import Foundation

struct StochRsiStrategy : Strategy{
    func getRequiredParameters() -> [ParameterRequirements] {
        return [
            ParameterRequirements(name: "rsiThreashold", minValue: 40, maxValue: 70, step: 5),  // added from 0 when long, subtracted from 100 when short
            ParameterRequirements(name: "rsiLimit", minValue: 0, maxValue: 20, step: 5),        // subtracted from 100 when long, added from 0 when short
            ParameterRequirements(name: "stochThreashold", minValue: 0, maxValue: 30, step: 5)  // added from 0 when long, subtracted from 100 when short
        ]
    }
    
    func getRequiredIndicators() -> [Indicator] {
        return [
            Indicator.atr(length: 14),
            Indicator.rsi(length: 20),
            Indicator.stoch(KLen: 14)
        ]
    }
    
    func backtest(chart: Chart, paramSet: ParameterSet) -> [SimulatedTrade] {
        let rsiThreashold = paramSet.parameters.filter{$0.name == "rsiThreashold"}.first!.value
        let rsiLimit = paramSet.parameters.filter{$0.name == "rsiLimit"}.first!.value
        let stochThreashold = paramSet.parameters.filter{$0.name == "stochThreashold"}.first!.value
        let tradeManager = TradeManager()
        
        var trade: UUID?

        for i in 1..<chart.candles.count-1 {
            if checkEntryCondition() {
                
            }
        }
        
        return tradeManager.finishBacktest()
    }
    
    private func checkEntryCondition() -> Bool {
        
        return false
    }
}
