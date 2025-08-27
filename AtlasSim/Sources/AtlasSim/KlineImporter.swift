//
//  KlineImporter.swift
//  AtlasSim
//
//  Created by Jannic Marcon on 27.08.2025.
//
import AtlasCore
import Foundation
import AtlasKit
import AtlasVault

public struct KlineImporter {
    public init() { }
    
    private let csvParser: CsvParser = .init()
    private let klineDataService: ChartDataService = .init()
    
    public func importChart(symbol: String, timeframe: Int, candles: [Candle]) async -> Bool {
        let newChart = Chart(name: symbol, timeframe: timeframe, candles: candles)
        return await klineDataService.importChart(newChart)
    }
    
    
    public func mergeAndFixCsv(urls: [URL]) throws -> [Candle] {
        var candles: [Candle] = []
        for url in urls {
            let newCandles = try csvParser.readCandlesFrom(url: url)
            candles.append(contentsOf: newCandles)
        }
        
        fixCandles(&candles)
        
        return candles
    }
    
    
    private func fixCandles(_ candles: inout [Candle]) {
        candles.sort { $0.time < $1.time }
        let isValid = validateTimestamps(of: candles)
        if isValid {
            var lastValidIndex: Int = 0
            for (index, candle) in candles.enumerated() {
                if candle.hasValidRange() {
                    let gap = index - lastValidIndex
                    if gap > 1 {
                        if gap > 10 {
                            print("gap of \(gap) fixed...")
                        }
                        
                        interpolateCandles(&candles, from: lastValidIndex, to: index)
                    }
                    lastValidIndex = index
                }
            }
        }
    }
    
    
    private func interpolateCandles(_ candles: inout [Candle], from start: Int, to end: Int) {
        let previous = candles[start]
        let next = candles[end]
        let count = end - start
        let totalMovement = next.close - previous.close
        let avgMove = totalMovement / Double(count)
        let wickSize = abs(avgMove) / 4

        for i in (start + 1)...end {
            let open = candles[i - 1].close
            if i != end {
                candles[i].close = open + avgMove
            }
            candles[i].open = open
            candles[i].high = max(open, open + avgMove) + wickSize
            candles[i].low = min(open, open + avgMove) - wickSize
        }

    }
    
    
    private func validateTimestamps(of candles: [Candle]) -> Bool {
        let timeDiff = candles[0].time - candles[1].time
        var lastTime = candles[0].time
        for candle in candles[1...] {
            if candle.time - lastTime != timeDiff {
                return false
            }
            lastTime = candle.time
        }
        return true
    }
}
