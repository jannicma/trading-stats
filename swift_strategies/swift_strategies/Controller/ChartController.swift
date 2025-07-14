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
    
    public func getAllChartsWithIndicaors() -> [String: [IndicatorCandle]] {
        let allChartPaths = CsvController.getAllCharts()
        var allCharts: [String: [IndicatorCandle]] = [:]
        
        let indicatorController = IndicatorController()
        
        for chartPath in allChartPaths {
            let currentChart = getChartWithIndicaors(filepath: chartPath, indicatorController: indicatorController)
            allCharts[chartPath] = currentChart
        }
        
        return allCharts
    }
}
