//
//  ChartController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 14.07.2025.
//
import Foundation

struct ChartController {
    private func validateChart(chart: [Candle]) -> Bool {
        //check for gaps in the candles
        var firstTimeGap: Int = 0
        var lastTime: Int = 0
        for candle in chart {
            if firstTimeGap > 0 {
                if lastTime + firstTimeGap != candle.time {
                    return false
                }
            }
            else{
                if lastTime > 0{
                    firstTimeGap = candle.time - lastTime
                }
            }
            lastTime = candle.time
        }
        
        return true
    }
    
    
    private func getChartWithIndicaors(filepaths: [URL], indicatorController: IndicatorController) -> [IndicatorCandle] {
        var candles: [Candle] = []
        for chartPart in filepaths {
            let part = CsvController.getCandles(path: chartPart)
            candles.append(contentsOf: part)
        }
        candles.sort { $0.time < $1.time }
        assert(validateChart(chart: candles), "There is a gap in the chart")
        
        return indicatorController.addIndicators(candles: candles, "sma200", "sma20", "sma5", "atr")
    }
    
    
    public func getAllChartsWithIndicaors() async -> [String: [IndicatorCandle]] {
        let allChartPaths = CsvController.getAllCharts().filter { $0.key != "bak" && $0.key != "tmp"  }
        var allCharts: [String: [IndicatorCandle]] = [:]
        
        let indicatorController = IndicatorController()
        
        await withTaskGroup(of: (String, [IndicatorCandle]).self) { group in
            for (name, files) in allChartPaths {
                group.addTask {
                    return (name, getChartWithIndicaors(filepaths: files, indicatorController: indicatorController))
                }
            }

            for await (name, data) in group {
                allCharts[name] = data
            }
        }

        
        return allCharts
    }
}
