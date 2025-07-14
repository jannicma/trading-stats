//
//  ChartController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 14.07.2025.
//

struct ChartController {
    private func getChartWithIndicaors(filepath: String, indicatorController: IndicatorController) -> [IndicatorCandle] {
        let candles = CsvController.getCandles(path: filepath)
        return indicatorController.addIndicators(candles: candles, "sma200", "sma20", "sma5", "atr")
    }
    
    public func getAllChartsWithIndicaors() async -> [String: [IndicatorCandle]] {
        let allChartPaths = CsvController.getAllCharts()
        var allCharts: [String: [IndicatorCandle]] = [:]
        
        let indicatorController = IndicatorController()
        
        await withTaskGroup(of: (String, [IndicatorCandle]).self) { group in
            for file in allChartPaths {
                group.addTask {
                    return (file, getChartWithIndicaors(filepath: file, indicatorController: indicatorController))
                }
            }

            for await (name, data) in group {
                allCharts[name] = data
            }
        }

        
        return allCharts
    }
}
