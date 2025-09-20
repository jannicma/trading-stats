//
//  DeribitPublicRest.swift
//  AtlasComms
//
//  Created by Jannic Marcon on 20.09.2025.
//
import AtlasCore
import Foundation

enum DeribitPublicRest {
    static func getHistoricalChart(for symbol: String, intervalMinutes: Int, limit: Int? = nil) async -> [Candle] {
        let limit = limit ?? 100
        let intervalMs = intervalMinutes * 60 * 1000
        let nowMs = Int(Date().timeIntervalSince1970 * 1000)
        let endTimestamp = nowMs - (nowMs % intervalMs) + intervalMs // round up
        let startTimestamp = endTimestamp - (limit * intervalMs)
        var urlComponents = URLComponents(string: "https://test.deribit.com/api/v2/public/get_tradingview_chart_data")!
        urlComponents.queryItems = [
            URLQueryItem(name: "instrument_name", value: symbol),
            URLQueryItem(name: "resolution", value: String(intervalMinutes)),
            URLQueryItem(name: "end_timestamp", value: String(endTimestamp)),
            URLQueryItem(name: "start_timestamp", value: String(startTimestamp)),
        ]
        guard let url = urlComponents.url else { return [] }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let apiResponse = try JSONDecoder().decode(HistoricalChartResponse.self, from: data)
            guard let r = apiResponse.result,
                  let ticks = r.ticks, let opens = r.open, let highs = r.high, let lows = r.low, let closes = r.close, let volumes = r.volume,
                  ticks.count == opens.count, ticks.count == highs.count, ticks.count == lows.count, ticks.count == closes.count, ticks.count == volumes.count else {
                return []
            }
            return (0..<ticks.count).map { idx in
                Candle(time: ticks[idx], open: opens[idx], high: highs[idx], low: lows[idx], close: closes[idx], volume: volumes[idx])
            }
        } catch {
            return []
        }
    }
}
