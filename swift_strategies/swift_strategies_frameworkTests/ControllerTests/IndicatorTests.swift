//
//  IndicatorTests.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 16.08.2025.
//

import Testing
import Foundation
@testable import swift_strategies_framework

struct IndicatorTests {
    private func getRequiredTestIndicators() -> [Indicator]{
        return [
            Indicator.sma(period: 5),
            Indicator.sma(period: 7),
            Indicator.atr(length: 5),
            Indicator.atr(length: 7),
            Indicator.rsi(length: 5),
            Indicator.rsi(length: 7),
            Indicator.stoch(KLen: 5),
            Indicator.stoch(KLen: 7)
        ]
    }
    
    @Test func validateIndicators() async throws {
        let fileUrl = URL(filePath: "/Users/jannicmarcon/Documents/ChartCsv/indicatorTesting/TEST-CHART-CSV.csv")!
        let testChart = CsvController.loadTestIndicatorChart(from: fileUrl)
        
        let ohlcChart = testChart.map { Candle(time: $0.time, open: $0.open, high: $0.high, low: $0.low, close: $0.close) }
        let IndicatorController = IndicatorController()
        let requiredIndicators = getRequiredTestIndicators()
        
        let computedIndicators = IndicatorController.computeIndicators(for: ohlcChart, requiredIndicators: requiredIndicators)
        
        for i in 0..<ohlcChart.count{
            if i < 40 { continue }
            
            let expectedCandle = testChart[i]
            
            let computedSma5 = computedIndicators["SMA5"]![i]
            let computedSma7 = computedIndicators["SMA7"]![i]
            let computedAtr5 = computedIndicators["ATR5"]![i]
            let computedAtr7 = computedIndicators["ATR7"]![i]
            let computedRsi5 = computedIndicators["RSI5"]![i]
            let computedRsi7 = computedIndicators["RSI7"]![i]
            let computedStoch5 = computedIndicators["STOCH5"]![i]
            let computedStoch7 = computedIndicators["STOCH7"]![i]
            
            #expect(abs(expectedCandle.sma5 - computedSma5) < 0.2, "SMA5 failed to compute correctly! Index \(i) - Timestammp: \(expectedCandle.time)")
            #expect(abs(expectedCandle.sma7 - computedSma7) < 0.2, "SMA7 failed to compute correctly! Index \(i) - Timestammp: \(expectedCandle.time)")
            #expect(abs(expectedCandle.atr5 - computedAtr5) < 0.2, "ATR5 failed to compute correctly! Index \(i) - Timestammp: \(expectedCandle.time)")
            #expect(abs(expectedCandle.atr7 - computedAtr7) < 0.2, "ATR7 failed to compute correctly! Index \(i) - Timestammp: \(expectedCandle.time)")
            #expect(abs(expectedCandle.rsi5 - computedRsi5) < 0.2, "RSI5 failed to compute correctly! Index \(i) - Timestammp: \(expectedCandle.time)")
            #expect(abs(expectedCandle.rsi7 - computedRsi7) < 0.2, "RSI7 failed to compute correctly! Index \(i) - Timestammp: \(expectedCandle.time)")
            #expect(abs(expectedCandle.stoch5 - computedStoch5) < 0.2, "STOCH5 failed to compute correctly! Index \(i) - Timestammp: \(expectedCandle.time)")
            #expect(abs(expectedCandle.stoch7 - computedStoch7) < 0.2, "STOCH7 failed to compute correctly! Index \(i) - Timestammp: \(expectedCandle.time)")
        }
    }

}
