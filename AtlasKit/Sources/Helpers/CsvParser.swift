//
//  CsvParser.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 27.08.2025.
//
import Foundation
import AtlasCore

public struct CsvParser {
    public init() {}
    
    public func readCandlesFrom(url: URL) throws -> [Candle] {
        var candles: [Candle] = []

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            var lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            if lines.first?.contains("open") == true {
                lines.removeFirst()
            }
            
            candles = lines.map { line in
                let values = line.split(separator: ",")
                return Candle(
                    time: Int(values[0])!,
                    open: Double(values[1])!,
                    high: Double(values[2])!,
                    low: Double(values[3])!,
                    close: Double(values[4])!,
                    volume: Double(values[5])!
                )
            }
        } catch {
            print(error)
        }

        return candles
    }
}
