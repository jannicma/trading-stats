//
//  CsvController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

import Foundation

struct CsvController {
    static public func getCandles(path: URL) -> [Candle] {
        var candles: [Candle] = []
        
        do {
            let content = try String(contentsOf: path, encoding: .utf8)
            var lines = content.components(separatedBy: .newlines).filter{ !$0.isEmpty }
            if lines.first!.contains("time") { lines.removeFirst() }
            
            candles = lines.map{ line in
                let values = line.split(separator: ",")
                return Candle( time: Int(values[0])!,
                               open: Double(values[1])!,
                               high: Double(values[2])!,
                               low: Double(values[3])!,
                               close: Double(values[4])!
                )
            }
        } catch {
            print(error)
        }
        
        return candles
    }
    
    
    static func convertToCSV<T: Encodable>(_ objects: [T]) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(objects)
        let jsonObjects = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []

        guard !jsonObjects.isEmpty else { return "" }

        let headers = ["time", "open", "high", "low", "close"]
        var rows: [String] = [headers.joined(separator: ",")]

        for dict in jsonObjects {
            let row = headers.map { "\(dict[$0] ?? "")" }.joined(separator: ",")
            rows.append(row)
        }

        return rows.joined(separator: "\n")
    }

    
    static func getAllCharts() -> [String: [URL]]{
        var result: [String: [URL]] = [:]
        let fileManager = FileManager.default
        let rootURL = URL(string: "/Users/jannicmarcon/Documents/ChartCsv")!

        do {
            let folderURLs = try fileManager.contentsOfDirectory(at: rootURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])

            for folderURL in folderURLs {
                let resourceValues = try folderURL.resourceValues(forKeys: [.isDirectoryKey])
                guard resourceValues.isDirectory == true else { continue }

                let folderName = folderURL.lastPathComponent
                if folderName == "bak" || folderName == "tmp"{
                    continue
                }
                
                let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])

                let csvFiles = fileURLs.filter { $0.pathExtension.lowercased() == "csv" }
                if !csvFiles.isEmpty {
                    result[folderName] = csvFiles
                }
            }
        } catch {
            print("Error: \(error)")
        }

        return result
    }

}
