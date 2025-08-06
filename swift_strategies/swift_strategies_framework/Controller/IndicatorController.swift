//
//  IndicatorController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//
import Foundation

struct IndicatorController {
    // MARK: - Configuration

    private let smaLengths: [String: Int] = [
        "sma200": 200,
        "sma20": 20,
        "sma5": 5
    ]

    private let atrLength = 14

    // MARK: - Public API

    public func computeIndicators(for candles: [Candle], indicators indicatorNames: [String]) -> [String: [Double]] {
        var indicators = makeEmptyIndicatorMap(from: indicatorNames)

        for name in indicatorNames {
            if let length = smaLengths[name] {
                indicators[name] = computeSimpleMovingAverage(on: candles, period: length)
            } else if name == "atr" {
                indicators[name] = computeAverageTrueRange(on: candles, period: atrLength)
            }
        }

        return indicators
    }

    // MARK: - Private Helpers

    private func makeEmptyIndicatorMap(from names: [String]) -> [String: [Double]] {
        var result: [String: [Double]] = [:]
        for name in names {
            result[name] = []
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
