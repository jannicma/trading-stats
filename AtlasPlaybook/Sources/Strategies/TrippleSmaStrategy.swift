//
//  TrippleSmaStrategy.swift
//  AtlasPlaybook
//
//  Created by Jannic Marcon on 23.08.2025.
//

import AtlasCore
import AtlasKit
import Foundation

public struct TrippleEmaStrategy: Strategy {
    public init(id: UUID) {
        self.id = id
    }

    public var id: UUID
    public var name = "Tripple SMA Strategy"

    public func getRequiredParameters() -> [ParameterRequirements] {
        return [
            ParameterRequirements(name: "tpAtrMult", minValue: 2, maxValue: 10, step: 0.5),
            ParameterRequirements(name: "slAtrMult", minValue: 1, maxValue: 7, step: 0.5),
        ]
    }

    public func getRequiredIndicators() -> [Indicator] {
        return [
            Indicator.sma(period: 5),
            Indicator.sma(period: 20),
            Indicator.sma(period: 200),
            Indicator.atr(length: 14),
        ]
    }

    public func onCandle(
        _ chart: Chart, orders: [Order], positions: [Position], paramSet: ParameterSet
    ) -> [TradeAction] {
        let tpMult = paramSet.parameters.filter { $0.name == "tpAtrMult" }.first!.value
        let slMult = paramSet.parameters.filter { $0.name == "slAtrMult" }.first!.value
        let lastIndex: Int = chart.candles.endIndex - 1
        let currCandle = chart.candles[lastIndex]
        var actions: [TradeAction] = []

        if !isCorrectOrder(index: lastIndex - 1, indicators: chart.indicators)
            && isCorrectOrder(index: lastIndex, indicators: chart.indicators)
            && positions.count == 0
        {
            //this is the entry logic. All EMA/SMA crossed into the right order.
            let atr = chart.indicators["ATR14"]![lastIndex]
            let action = createTrade(candle: currCandle, atr: atr, tpMult: tpMult, slMult: slMult)
            actions.append(action)
        }
        //Exits will be handled by TP and SL  //TODO: remove comment
        return actions
    }

    private func createTrade(candle: Candle, atr: Double, tpMult: Double, slMult: Double)
        -> TradeAction
    {
        assert(atr > 0)
        var entry: Double
        var slPrice: Double
        var tpPrice: Double
        var side: Side
        entry = candle.close

        if isBull(candle) {
            side = .long
            slPrice = entry - (slMult * atr)
            tpPrice = entry + (tpMult * atr)
        } else {
            side = .short
            slPrice = entry + (slMult * atr)
            tpPrice = entry - (tpMult * atr)
        }
        let volume = OrderHelper.computeVolume(
            slDistance: abs(entry - slPrice), startBalance: 100_000, riskPerTradePercentage: 0.02)
        let order = Order(
            id: UUID(), symbol: "", side: side, type: .market, quantity: volume, sl: slPrice,
            tp: tpPrice, entryType: .taker)
        return TradeAction.open(order: order)
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
