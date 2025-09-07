//
//  ChartService.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 25.08.2025.
//
import Foundation
import AtlasCore
import AtlasVault

public struct ChartService {
    public init(indicatorsToCompute: [Indicator]) {
        self.indicatorsToCompute = indicatorsToCompute
        self.chartDataHandler = .init()
        self.indicatorEngine = .init()
    }
    
    private let chartDataHandler: ChartDataHandler
    private let indicatorEngine: IndicatorEngine
    private let indicatorsToCompute: [Indicator]
    
    public func loadAllCharts(timeframes: [Int]) async -> [Chart] {
        var baseOneMinCharts: [Chart] = await chartDataHandler.getAllKlineCharts()
        var klineCharts: [Chart] = []
        let oneMinuteIndexes: [Int] = klineCharts.enumerated().map { $0.offset }
        
        for oneMinIndex in oneMinuteIndexes {
            let newGeneratedTimeframeChart = generateTimeframeCharts(of: baseOneMinCharts[oneMinIndex], timeframes: timeframes)
            klineCharts.append(contentsOf: newGeneratedTimeframeChart)
        }
        
        for (index, _) in klineCharts.enumerated() {
            addIndicatorsToChart(&klineCharts[index])
        }

        return klineCharts
    }
    
    
    private func generateTimeframeCharts(of baseChart: Chart, timeframes: [Int]) -> [Chart] {
        let baseCandles = baseChart.candles
        var allCharts: [Chart] = []
        
        for timeframe in timeframes {
            if timeframe == 1 {
                allCharts.append(baseChart)
                continue
            }
            
            var newCandles: [Candle] = []
            let newCandlesCount = Int(ceil(Double(baseCandles.count) / Double(timeframe)))
            for i in 1...newCandlesCount {
                let startIndex = (i - 1) * timeframe
                var endIndex = i * timeframe - 1
                if endIndex >= baseCandles.count {
                    endIndex = baseCandles.count - 1
                }
                
                let time = baseCandles[startIndex].time
                let open = baseCandles[startIndex].open
                let close = baseCandles[endIndex].close
                let high = baseCandles[startIndex...endIndex].max(by: { $0.high < $1.high })?.high ?? 0
                let low = baseCandles[startIndex...endIndex].min(by: { $0.low < $1.low })?.low ?? 0
                let volume = baseCandles[startIndex...endIndex].map{$0.volume} .reduce(0.0, +)
                
                let newCandle = Candle(time: time, open: open, high: high, low: low, close: close, volume: volume)
                newCandles.append(newCandle)
            }
            
            let newChart = Chart(name: baseChart.name, timeframe: timeframe, candles: newCandles)
            allCharts.append(newChart)
        }
        return allCharts
    }
    
    
    private func addIndicatorsToChart(_ chart: inout Chart) {
        chart.indicators = indicatorEngine.computeIndicators(for: chart.candles, requiredIndicators: indicatorsToCompute)
    }
}
