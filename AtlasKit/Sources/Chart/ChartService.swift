//
//  ChartService.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 25.08.2025.
//
import Foundation
import AtlasCore
import AtlasVault

public struct ChartService: Sendable {
    public init(indicatorsToCompute: [Indicator]) {
        self.indicatorsToCompute = indicatorsToCompute
        self.chartDataService = .init()
        self.indicatorEngine = .init()
    }
    
    private let chartDataService: ChartDataService
    private let indicatorEngine: IndicatorEngine
    private let indicatorsToCompute: [Indicator]
    
    public func loadAllCharts(timeframes: [Int]) -> [Chart] {
        var klineCharts: [Chart] = chartDataService.getAllKlineCharts()
        var oneMinuteIndexes: [Int] = klineCharts.enumerated().map { $0.offset }
        
        for oneMinIndex in oneMinuteIndexes {
            let newGeneratedTimeframeChart = generateTimeframeCharts(of: klineCharts[oneMinIndex], timeframes: timeframes)
            klineCharts.append(contentsOf: newGeneratedTimeframeChart)
        }
        
        for (index, _) in klineCharts.enumerated() {
            addIndicatorsToChart(&klineCharts[index])
        }

        return klineCharts
    }
    
    
    private func generateTimeframeCharts(of baseChart: Chart, timeframes: [Int]) -> [Chart] {
        //TODO: make function
        return []
    }
    
    
    private func addIndicatorsToChart(_ chart: inout Chart) {
        chart.indicators = indicatorEngine.computeIndicators(for: chart.candles, requiredIndicators: indicatorsToCompute)
    }
}
