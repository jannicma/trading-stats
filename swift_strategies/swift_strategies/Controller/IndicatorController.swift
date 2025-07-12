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
    

    public func addIndicators(candles: [Candle], _ indicators: String...) -> [IndicatorCandle] {
        var indicatorCandles: [IndicatorCandle] = []
        
        let minCandleAmount = calcMinCandleAmount(indicators)

        for i in minCandleAmount..<candles.count {
            var newIndicatorCandle = IndicatorCandle(ohlc: candles[i])
            
            if indicators.contains("sma200") {
                newIndicatorCandle.sma200 = calcSma(candles: candles, ind: i, smaLen: sma200Len)
            }

            if indicators.contains("sma20") {
                newIndicatorCandle.sma20 = calcSma(candles: candles, ind: i, smaLen: sma20Len)
            }

            if indicators.contains("sma5") {
                newIndicatorCandle.sma5 = calcSma(candles: candles, ind: i, smaLen: sma5Len)
            }

            if indicators.contains("atr") {
                newIndicatorCandle.atr = calcAtr(candles: candles, ind: i)
            }

            if indicators.contains("atr%") {
                newIndicatorCandle.atrPercentage = calcAtrPercentage(candles: candles, ind: i)
            }

            indicatorCandles.append(newIndicatorCandle)
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


    private func calcSma(candles: [Candle], ind: Int, smaLen: Int) -> Double {
        var closeSum = 0.0

        for i in ind-smaLen+1...ind {
            closeSum += candles[i].close
        }

        return closeSum / Double(smaLen)
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
