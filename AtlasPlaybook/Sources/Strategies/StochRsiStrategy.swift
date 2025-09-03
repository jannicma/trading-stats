//
//  StochRsiStrategy.swift
//  AtlasPlaybook
//
//  Created by Jannic Marcon on 23.08.2025.
//

import Foundation
import AtlasCore
import AtlasKit

public struct StochRsiStrategy : Strategy{
    public init(id: UUID) {
        self.id = id
    }
    
    public var id: UUID
    public var name = "Stochastic/RSI Strategy"
    
    public func getRequiredParameters() -> [ParameterRequirements] {
        return [
            ParameterRequirements(name: "rsiThreashold", minValue: 40, maxValue: 70, step: 5),  // added from 0 when long, subtracted from 100 when short
            ParameterRequirements(name: "rsiLimit", minValue: 0, maxValue: 20, step: 5),        // subtracted from 100 when long, added from 0 when short
            ParameterRequirements(name: "stochThreashold", minValue: 5, maxValue: 30, step: 5)  // added from 0 when long, subtracted from 100 when short
        ]
    }
    
    var atrIndicator = Indicator.atr(length: 14)
    var rsiIndicator = Indicator.rsi(length: 14)
    var stochIndicaor = Indicator.stoch(KLen: 14)
    
    public func getRequiredIndicators() -> [Indicator] {
        return [atrIndicator, rsiIndicator, stochIndicaor]
    }
    
    enum DirectionForTrade: Codable, Sendable{
        case long
        case short
        case none
    }
    
    struct TradeConditions: Codable, Sendable{
        var rsiThreashold: Double
        var rsiLimit: Double
        var stochThreashold: Double
    }
    
    public func backtest(chart: Chart, paramSet: ParameterSet) -> [Trade] {
        let tradeManager = TradeManager()
        let rsiThreasholdParam = paramSet.parameters.filter{$0.name == "rsiThreashold"}.first!.value
        let rsiLimitParam = paramSet.parameters.filter{$0.name == "rsiLimit"}.first!.value
        let stochThreasholdParam = paramSet.parameters.filter{$0.name == "stochThreashold"}.first!.value
        
        let longCondition = TradeConditions(rsiThreashold: rsiThreasholdParam, rsiLimit: 100-rsiLimitParam, stochThreashold: stochThreasholdParam)
        let shortCondition = TradeConditions(rsiThreashold: 100-rsiThreasholdParam, rsiLimit: rsiLimitParam, stochThreashold: 100-stochThreasholdParam)
        
        var trade: UUID? = nil

        for i in 1..<chart.candles.count-1 {
            let close = chart.candles[i].close

            let stochValue = chart.indicators[stochIndicaor.name]![i]
            let direction = directionFrom(stoch: stochValue, threashold: stochThreasholdParam)
            if direction == .none { continue }
            
            let rsiValue = chart.indicators[rsiIndicator.name]![i]
            let currentCondition = direction == .long ? longCondition : shortCondition
            
            if trade == nil && checkEntryCondition(side: direction, rsi: rsiValue, stoch: stochValue, conditions: currentCondition) {
                let atr = chart.indicators[atrIndicator.name]![i]
                let time = chart.candles[i].time
                let sl = close + ((2*atr) * (direction == .long ? -1 : 1))
                let tp = close + ((30*atr) * (direction == .long ? 1 : -1))
                let volume = tradeManager.computeVolume(slDistance: abs(sl-close))
                trade = tradeManager.enter(time: time, open: close, volume: volume, sl: sl, tp: tp, atr: atr)
            }
            
            if trade != nil {
                let openTrade = tradeManager.get(trade!)
                let tradeDirection: DirectionForTrade = openTrade.entryPrice > openTrade.slPrice ? .long : .short
                let condition = tradeDirection == .long ? longCondition : shortCondition
                let hitSl = tradeDirection == .long ? close <= openTrade.slPrice : close >= openTrade.slPrice
                if hitSl || checkExitCondition(rsi: rsiValue, tradeDirection: tradeDirection, tradeConditions: condition){
                    _ = tradeManager.exit(trade!, close: close)
                    trade = nil
                }
            }

        }
        
        return tradeManager.finishBacktest()
    }
    
    private func directionFrom(stoch: Double, threashold: Double) -> DirectionForTrade {
        if stoch < threashold {
            return .long
        } else if stoch > 100-threashold {
            return .short
        } else {
            return .none
        }
    }
    
    private func checkEntryCondition(side: DirectionForTrade, rsi: Double, stoch: Double, conditions: TradeConditions) -> Bool {
        var isValidEntryCondition: Bool = false
        
        if side == .long {
            isValidEntryCondition = rsi >= conditions.rsiThreashold && rsi <= conditions.rsiLimit && stoch <= conditions.stochThreashold
        }
        
        if side == .short {
            isValidEntryCondition = rsi <= conditions.rsiThreashold && rsi >= conditions.rsiLimit && stoch >= conditions.stochThreashold
        }
        
        return isValidEntryCondition
    }
    
    private func checkExitCondition(rsi: Double, tradeDirection: DirectionForTrade, tradeConditions: TradeConditions) -> Bool {
        if tradeDirection == .long {
            return rsi < tradeConditions.rsiThreashold - 5
        }
        else {
            return rsi > tradeConditions.rsiThreashold + 5
        }
    }
}
