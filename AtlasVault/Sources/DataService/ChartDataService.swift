//
//  ChartDataService.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 26.08.2025.
//
import AtlasCore
import GRDB

public struct ChartDataService {
    public init () { }
    
    public func getAllCharts() async throws -> [Chart] {
        let symbols: [String] = try await DatabaseManager.shared.read { db in
            try String
                .fetchAll(
                    db,
                    KlineDto
                        .select(\.symbol)
                        .distinct()
                )
        }
        
        var charts: [Chart] = []
        for symbol in symbols {
            let name: String = symbol
            let allAssociatedKlines = try await DatabaseManager.shared.read { db in
                try KlineDto
                    .filter{$0.symbol == symbol}
                    .fetchAll(db)
            }
            
            let candles: [Candle] = allAssociatedKlines.map { Candle(time: $0.timestamp, open: $0.open, high: $0.high, low: $0.low, close: $0.close, volume: $0.volume) }
            let newChart = Chart(name: name, timeframe: 1, candles: candles)
            charts.append(newChart)
        }
        
        return charts
    }
    
    
    public func importChart(_ chart: Chart) async -> Bool {
        let name = chart.name
        let timeframe = chart.timeframe
        
        let klines: [KlineDto] = chart.candles.map {
            KlineDto(
                symbol: name,
                timeframe: timeframe,
                timestamp: $0.time,
                open: $0.open,
                high: $0.high,
                low: $0.low,
                close: $0.close,
                volume: $0.volume
            )
        }
        
        do {
            try await DatabaseManager.shared.write { db in
                for kline in klines {
                    try kline.insert(db)
                }
            }
            return true
        } catch {
            return false
        }
    }
}
