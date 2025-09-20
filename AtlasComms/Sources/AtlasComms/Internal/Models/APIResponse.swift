//
//  APIResponse.swift
//  AtlasComms
//
//  Created by Jannic Marcon on 20.09.2025.
//


struct HistoricalChartResponse: Decodable {
    struct Result: Decodable {
        let volume: [Double]?
        let open: [Double]?
        let high: [Double]?
        let low: [Double]?
        let close: [Double]?
        let ticks: [Int]?
    }
    let result: Result?
}
