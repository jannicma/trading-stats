//
//  IndicatorController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

import Foundation

struct IndicatorController {
    let sma200Len = 200
    let sma20Len = 20
    let sma5Len = 5
    let atrLen = 14
    
    //TODO: test
    private func initIndicators(names: [String]) -> [String: [Double]] {
        var indicators: [String: [Double]] = [:]
        for name in names {
            indicators[name] = []
        }
        return indicators
    }
    
    
    //TODO: test
    public func getIndicators(candles: [Candle], _ indicatorNames: String...) -> [String: [Double]] {
        var indicators: [String: [Double]] = initIndicators(names: indicatorNames)
        
        if indicatorNames.contains("sma200") {
            let values = calcSma(candles: candles, smaLen: sma200Len)
            indicators["sma200"] = values
        }

        if indicatorNames.contains("sma20") {
            let values = calcSma(candles: candles, smaLen: sma20Len)
            indicators["sma20"] = values
        }

        if indicatorNames.contains("sma5") {
            let values = calcSma(candles: candles, smaLen: sma5Len)
            indicators["sma5"] = values
        }

        if indicatorNames.contains("atr") {
            let values = calcAtr(candles: candles)
            indicators["atr"] = values
        }

        return indicators
    }

    
    //TODO: test
    private func calcAtr(candles: [Candle]) -> [Double] {
        var rangeBuffer: [Double] = []
        var atrArray: [Double] = []
        
        for i in 0..<candles.count {
            let range = abs(candles[i].high - candles[i].low)
            rangeBuffer.append(range)
            
            if rangeBuffer.count < atrLen {
                atrArray.append(0.0)
                continue
            }
            
            let rangeSum = rangeBuffer.reduce(0, +)
            let averageRange = rangeSum / Double(atrLen)
            atrArray.append(averageRange)
            
            rangeBuffer.removeFirst()
        }
        return atrArray
    }


    //TODO: test
    private func calcSma(candles: [Candle], smaLen: Int) -> [Double] {
        var closesBuffer: [Double] = []
        var smaArray: [Double] = []
        
        for i in 0..<candles.count {
            closesBuffer.append(candles[i].close)

            if closesBuffer.count < smaLen {
                smaArray.append(0.0)
                continue
            }
            let sum = closesBuffer.reduce(0, +)
            let average = sum / Double(smaLen)
            smaArray.append(average)
            closesBuffer.removeFirst()
        }
        return smaArray
    }
}
