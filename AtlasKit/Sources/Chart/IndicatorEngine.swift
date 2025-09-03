//
//  IndicatorEngine.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 23.08.2025.
//

import Foundation
import AtlasCore

struct IndicatorEngine {
    
    // MARK: - Public API

    public func computeIndicators(for candles: [Candle], requiredIndicators: [Indicator]) -> [String: [Double]] {
        var indicators = makeEmptyIndicatorMap(from: requiredIndicators)

        for indicator in requiredIndicators {
            switch indicator{
            case .sma(let period):
                indicators[indicator.name] = computeSimpleMovingAverage(on: candles, period: period)
            case .atr(let length):
                indicators[indicator.name] = computeAverageTrueRange(on: candles, length: length)
            case .rsi(let length):
                indicators[indicator.name] = computeRelativeStrengthIndex(on: candles, length: length)
            case .stoch(let kLength):
                indicators[indicator.name] = computeStochasticOscillator(on: candles, kLength: kLength)
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

    private func computeAverageTrueRange(on candles: [Candle], length: Int) -> [Double] {
        var buffer: [Double] = []
        var result: [Double] = []

        for candle in candles {
            let range = abs(candle.high - candle.low)
            buffer.append(range)

            if buffer.count < length {
                result.append(0.0)
                continue
            }

            let averageRange = buffer.reduce(0, +) / Double(length)
            result.append(averageRange)
            buffer.removeFirst()
        }

        return result
    }
    
    private func computeRelativeStrengthIndex(on candles: [Candle], length: Int) -> [Double] {
        let n = candles.count
        guard length > 0, n > 1 else { return Array(repeating: 0.0, count: n) }

        var result = Array(repeating: 0.0, count: n)

        func rsi(from avgGain: Double, _ avgLoss: Double) -> Double {
            if avgLoss == 0 {
                if avgGain == 0 { return 50.0 }  // flat window
                return 100.0                     // all gains, no losses
            }
            let rs = avgGain / avgLoss
            return 100.0 - (100.0 / (1.0 + rs))
        }

        // --- Initial average gains/losses over first `length` deltas ---
        var sumGain = 0.0
        var sumLoss = 0.0

        for i in 1...min(length, n - 1) {
            let change = candles[i].close - candles[i - 1].close
            if change > 0 {
                sumGain += change
            } else {
                sumLoss += -change
            }
        }

        if n <= length { return result } // not enough data to compute RSI

        var avgGain = sumGain / Double(length)
        var avgLoss = sumLoss / Double(length)
        result[length] = rsi(from: avgGain, avgLoss)

        // --- Wilder smoothing for the rest ---
        if n > length + 1 {
            for i in (length + 1)..<n {
                let change = candles[i].close - candles[i - 1].close
                let gain = change > 0 ? change : 0.0
                let loss = change < 0 ? -change : 0.0

                avgGain = ((avgGain * Double(length - 1)) + gain) / Double(length)
                avgLoss = ((avgLoss * Double(length - 1)) + loss) / Double(length)

                result[i] = rsi(from: avgGain, avgLoss)
            }
        }

        return result
    }
    
    private func computeStochasticOscillator(on candles: [Candle], kLength: Int) -> [Double] {
        var highBuffer: [Double] = []
        var lowBuffer: [Double] = []
        var result: [Double] = []
        
        for candle in candles{
            highBuffer.append(candle.high)
            lowBuffer.append(candle.low)
            
            if highBuffer.count < kLength {
                result.append(0.0)
                continue
            }
            
            let highestHigh = highBuffer.max() ?? 0.0
            let lowestLow = lowBuffer.min() ?? 0.0
            
            let dividend = candle.close - lowestLow
            let divisor = highestHigh - lowestLow
            result.append(dividend / divisor * 100.0)
            
            highBuffer.removeFirst()
            lowBuffer.removeFirst()
        }
        return result
    }
}
