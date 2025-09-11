//
//  CandleBreakoutStrategy.swift
//  AtlasPlaybook
//
//  Created by Jannic Marcon on 06.09.2025.
//

import AtlasCore
import AtlasKit
import Foundation

public struct CandleBreakoutStrategy: Strategy {
    public var name: String = "Candle Breakout Strategy"
    public var id: UUID
    public init(id: UUID) {
        self.id = id
    }

    public func getRequiredParameters() -> [ParameterRequirements] {
        return [
            ParameterRequirements(name: "entryLookbackCandles", minValue: 1, maxValue: 5, step: 1),
            ParameterRequirements(name: "exitLookbackCandles", minValue: 1, maxValue: 5, step: 1),
        ]
    }

    var atrIndicator = Indicator.atr(length: 14)
    public func getRequiredIndicators() -> [Indicator] {
        return [atrIndicator]
    }

    public func onCandle(
        _ chart: Chart, orders: [Order], positions: [Position], paramSet: ParameterSet
    ) -> [TradeAction] {
        let entryLookback = paramSet.parameters.filter { $0.name == "entryLookbackCandles" }.first!
            .value
        let exitLookback = paramSet.parameters.filter { $0.name == "exitLookbackCandles" }.first!
            .value

        var actions: [TradeAction] = []
        let idx: Int = chart.candles.count - 1
        let candle: Candle = chart.candles[idx]

        if idx < max(Int(entryLookback), Int(exitLookback)) { return [] }
        let exitCompareCandle = chart.candles[idx - Int(exitLookback)]

        //update exit sl
        if positions.count > 0 {
            for position in positions {
                var newSl: Double
                switch position.side {
                case .long:
                    newSl = exitCompareCandle.low
                case .short:
                    newSl = exitCompareCandle.high
                }
                let update = PositionUpdate(newSL: newSl, newTP: nil)
                let action = TradeAction.modifyPosition(positionId: position.id, update: update)
                actions.append(action)
            }
        }

        //check entry
        let entryCompareCandle = chart.candles[idx - Int(entryLookback)]
        var startSL: Double?
        if candle.high > entryCompareCandle.high {
            startSL = exitCompareCandle.low
            let vol = OrderHelper.computeVolume(
                slDistance: candle.close - startSL!, startBalance: 100_000,
                riskPerTradePercentage: 0.02)
            let marketOrder = Order(
                id: UUID(), symbol: chart.name, side: .long, type: .market, quantity: vol,
                sl: startSL, tp: nil, entryType: .taker)
            let newAction = TradeAction.open(order: marketOrder)
            actions.append(newAction)
        } else if candle.low < entryCompareCandle.low {
            startSL = exitCompareCandle.high
            let vol = OrderHelper.computeVolume(
                slDistance: abs(candle.close - startSL!), startBalance: 100_000,
                riskPerTradePercentage: 0.02)
            let marketOrder = Order(
                id: UUID(), symbol: chart.name, side: .short, type: .market, quantity: vol,
                sl: startSL, tp: nil, entryType: .taker)
            let newAction = TradeAction.open(order: marketOrder)
            actions.append(newAction)
        }
        return actions
    }
}
