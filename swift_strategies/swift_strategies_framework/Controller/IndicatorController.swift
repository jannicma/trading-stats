//
//  IndicatorController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//
import Foundation

struct IndicatorController {
    
    // MARK: - Public API

    public func computeIndicators(for candles: [Candle], requiredIndicators: [Indicator]) -> [String: [Double]] {
        var indicators = makeEmptyIndicatorMap(from: requiredIndicators)

        for indicator in requiredIndicators {
            switch indicator{
            case .sma(let period):
                indicators[indicator.name] = computeSimpleMovingAverage(on: candles, period: period)
            case .atr(let length):
                indicators[indicator.name] = computeAverageTrueRange(on: candles, period: length)
            }
        }

        return indicators
    }

    // MARK: - Private Helpers

    private func makeEmptyIndicatorMap(from indicators: [Indicator]) -> [String: [Double]] {
        var result: [String: [Double]] = [:]
        for indicator in indicators {
            result[indicator.name] = []
        }
        return result
    }

    private func computeSimpleMovingAverage(on candles: [Candle], period: Int) -> [Double] {
        var buffer: [Double] = []
        var result: [Double] = []

        for candle in candles {
            buffer.append(candle.close)

            if buffer.count < period {
                result.append(0.0)
                continue
            }

            let average = buffer.reduce(0, +) / Double(period)
            result.append(average)

            buffer.removeFirst()
        }

        return result
    }

    private func computeAverageTrueRange(on candles: [Candle], period: Int) -> [Double] {
        var buffer: [Double] = []
        var result: [Double] = []

        for candle in candles {
            let range = abs(candle.high - candle.low)
            buffer.append(range)

            if buffer.count < period {
                result.append(0.0)
                continue
            }

            let averageRange = buffer.reduce(0, +) / Double(period)
            result.append(averageRange)

            buffer.removeFirst()
        }

        return result
    }
}
