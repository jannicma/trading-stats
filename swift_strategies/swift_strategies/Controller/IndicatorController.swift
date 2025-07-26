//
//  IndicatorController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

import Foundation

struct IndicatorController {
    let sma200Len = 200
    let sma20Len = 20
    let sma5Len = 5
    let atrLen = 14
    
    private func initIndicators(names: [String]) -> [String: [Double]] {
        var indicators: [String: [Double]] = [:]
        for name in names {
            indicators[name] = []
        }
        return indicators
    }
    
    
    public func getIndicators(candles: [Candle], _ indicatorNames: String...) -> [String: Double] {
        var indicators: [String: [Double]] = initIndicators(names: indicatorNames)
        
        let minCandleAmount = calcMinCandleAmount(indicatorNames)

        if indicatorNames.contains("sma200") {
            var a = calcSma(candles: candles, smaLen: sma200Len)
        }

        if indicatorNames.contains("sma20") {
            var b = calcSma(candles: candles, smaLen: sma20Len)
        }

        if indicatorNames.contains("sma5") {
            var c = calcSma(candles: candles, ind: i, smaLen: sma5Len)
        }

        if indicatorNames.contains("atr") {
            var d = calcAtr(candles: candles, ind: i)
        }

        if indicatorNames.contains("atr%") {
            var e = calcAtrPercentage(candles: candles, ind: i)
        }

        return indicatorCandles
    }


    private func calcAtrPercentage(candles: [Candle], ind: Int) -> Double {
        let atr = calcAtr(candles: candles, ind: ind)
        let close = candles[ind].close

        return round((100 / close * atr) * 100) / 100
    }


    private func calcAtr(candles: [Candle], ind: Int) -> Double {
        var addedRanges = 0.0

        for i in ind-atrLen+1...ind {
            let candle = candles[i]
            let range = abs(candle.high - candle.low)
            addedRanges += range
        }

        return addedRanges / Double(atrLen)
    }


    private func calcSma(candles: [Candle], smaLen: Int) -> [Double] {
        var candleBuffer: [Double] = []
        var smaArray: [Double] = []
        
        for i in 0..<candles.count {
            if candleBuffer.count < smaLen {
                candleBuffer.append(candles[i].close)
                smaArray.append(0)
                continue
            }
            var sum = candleBuffer.reduce(0, +)
            var average = sum / Double(smaLen)
            smaArray.append(average)
            candleBuffer.removeFirst()
        }
        return smaArray
    }


    private func calcMinCandleAmount(_ indicators: [String]) -> Int {
        var minAmount = 0

        for indicator in indicators {
            switch indicator {
                case "sma200":
                    minAmount = max(minAmount, sma200Len)
                case "sma20":
                    minAmount = max(minAmount, sma20Len)
                case "sma5":
                    minAmount = max(minAmount, sma5Len)
                case "atr", "atr%":
                    minAmount = max(minAmount, atrLen)
                default:
                    print("invalid indicator name")
            }
        }

        return minAmount
    }
}
