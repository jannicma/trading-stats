//
//  StochRsiStrategy.swift
//  AtlasPlaybook
//
//  Created by Jannic Marcon on 23.08.2025.
//

import AtlasCore
import AtlasKit
import Foundation

public struct StochRsiStrategy: Strategy {
    public init(id: UUID) {
        self.id = id
    }

    public var id: UUID
    public var name = "Stochastic/RSI Strategy"

    public func getRequiredParameters() -> [ParameterRequirements] {
        return [
            ParameterRequirements(name: "rsiThreashold", minValue: 40, maxValue: 70, step: 5),  // added from 0 when long, subtracted from 100 when short
            ParameterRequirements(name: "rsiLimit", minValue: 0, maxValue: 20, step: 5),  // subtracted from 100 when long, added from 0 when short
            ParameterRequirements(name: "stochThreashold", minValue: 5, maxValue: 30, step: 5),  // added from 0 when long, subtracted from 100 when short
        ]
    }

    var atrIndicator = Indicator.atr(length: 14)
    var rsiIndicator = Indicator.rsi(length: 14)
    var stochIndicaor = Indicator.stoch(KLen: 14)

    public func getRequiredIndicators() -> [Indicator] {
        return [atrIndicator, rsiIndicator, stochIndicaor]
    }

    enum DirectionForTrade: Codable, Sendable {
        case long
        case short
        case none
    }

    struct TradeConditions: Codable, Sendable {
        var rsiThreashold: Double
        var rsiLimit: Double
        var stochThreashold: Double
    }

    public func onCandle(
        _ chart: Chart, orders: [Order], positions: [Position], paramSet: ParameterSet
    ) -> [TradeAction] {
        let rsiThreasholdParam = paramSet.parameters.filter { $0.name == "rsiThreashold" }.first!
            .value
        let rsiLimitParam = paramSet.parameters.filter { $0.name == "rsiLimit" }.first!.value
        let stochThreasholdParam = paramSet.parameters.filter { $0.name == "stochThreashold" }
            .first!.value
        let longCondition = TradeConditions(
            rsiThreashold: rsiThreasholdParam, rsiLimit: 100 - rsiLimitParam,
            stochThreashold: stochThreasholdParam)
        let shortCondition = TradeConditions(
            rsiThreashold: 100 - rsiThreasholdParam, rsiLimit: rsiLimitParam,
            stochThreashold: 100 - stochThreasholdParam)
        let lastIndex = chart.candles.count - 1
        var actions: [TradeAction] = []

        let close = chart.candles[lastIndex].close
        let stochValue = chart.indicators[stochIndicaor.name]![lastIndex]
        let direction = directionFrom(stoch: stochValue, threashold: stochThreasholdParam)
        let rsiValue = chart.indicators[rsiIndicator.name]![lastIndex]
        let currentCondition = direction == .long ? longCondition : shortCondition

        if positions.count == 0 && direction != .none
            && checkEntryCondition(
                side: direction, rsi: rsiValue, stoch: stochValue, conditions: currentCondition)
        {
            let atr = chart.indicators[atrIndicator.name]![lastIndex]
            let time = chart.candles[lastIndex].time
            let sl = close + ((2 * atr) * (direction == .long ? -1 : 1))
            let tp = close + ((30 * atr) * (direction == .long ? 1 : -1))
            let volume = OrderHelper.computeVolume(
                slDistance: abs(sl - close), startBalance: 100_000, riskPerTradePercentage: 0.02)
            let side: Side = direction == .long ? .long : .short
            let newOrder = Order(
                id: UUID(), symbol: chart.name, side: side, type: .market, quantity: volume, sl: sl,
                tp: tp, entryType: .taker)
            let newAction = TradeAction.open(order: newOrder)
            actions.append(newAction)
        }

        return actions
    }

    private func directionFrom(stoch: Double, threashold: Double) -> DirectionForTrade {
        if stoch < threashold {
            return .long
        } else if stoch > 100 - threashold {
            return .short
        } else {
            return .none
        }
    }

    private func checkEntryCondition(
        side: DirectionForTrade, rsi: Double, stoch: Double, conditions: TradeConditions
    ) -> Bool {
        var isValidEntryCondition: Bool = false

        if side == .long {
            isValidEntryCondition =
                rsi >= conditions.rsiThreashold && rsi <= conditions.rsiLimit
                && stoch <= conditions.stochThreashold
        }

        if side == .short {
            isValidEntryCondition =
                rsi <= conditions.rsiThreashold && rsi >= conditions.rsiLimit
                && stoch >= conditions.stochThreashold
        }

        return isValidEntryCondition
    }
}
