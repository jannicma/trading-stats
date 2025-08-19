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
            buffer.removeFirst()
        }

        return result
    }
    
    private func computeRelativeStrengthIndex(on candles: [Candle], length: Int) -> [Double] {
        let n = candles.count
        guard length > 0, n > 1 else { return Array(repeating: 0.0, count: n) }

        var result = Array(repeating: 0.0, count: n)

        // Prepare sums over the first `length` deltas (which span length+1 candles)
        var sumGain: Double = 0
        var sumLoss: Double = 0

        // Build initial sums from close-to-close deltas
        for i in 1...length where i < n {
            let change = candles[i].close - candles[i - 1].close
            if change > 0 { sumGain += change } else { sumLoss += -change }
        }

        // If we don't even have length+1 candles, we cannot initialize RSI
        if n <= length { return result }

        var avgGain = sumGain / Double(length)
        var avgLoss = sumLoss / Double(length)

        // Compute RSI for the first index where it becomes defined
        func rsi(from avgGain: Double, _ avgLoss: Double) -> Double {
            if avgLoss == 0 {
                if avgGain == 0 { return 50 } // no movement
                return 100                     // all gains, no losses
            }
            let rs = avgGain / avgLoss
            return 100 - (100 / (1 + rs))
        }

        result[length] = rsi(from: avgGain, avgLoss)

        // Wilder smoothing for the rest
        if n > length + 1 {
            for i in (length + 1)..<n {
                let change = candles[i].close - candles[i - 1].close
                let gain = change > 0 ? change : 0
                let loss = change < 0 ? -change : 0

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
