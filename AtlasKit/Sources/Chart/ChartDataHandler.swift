//
//  ChartDataService.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 25.08.2025.
//
import AtlasCore
import AtlasVault

struct ChartDataHandler {
    init(){
        self.chartDataService = .init()
    }
    
    private let chartDataService: ChartDataService
    
    
    public func getAllKlineCharts() async -> [Chart] {
        var charts: [Chart] = []
        do {
            charts = try await chartDataService.getAllCharts()
        }
        catch {
            let message = "Error fetching all charts: \(error)"
            await Logger.shared.log(message)
        }
        return charts
    }
}
