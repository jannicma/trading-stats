//
//  CsvController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//
import Foundation

struct CsvController {
    
    // MARK: - Public API

    static public func loadCandles(from fileURL: URL) -> [Candle] {
        var candles: [Candle] = []

        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            var lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            if lines.first?.contains("time") == true {
                lines.removeFirst()
            }
            
            candles = lines.map { line in
                let values = line.split(separator: ",")
                return Candle(
                    time: Int(values[0])!,
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

    static public func loadTestIndicatorChart(from fileURL: URL) -> [TestIndicatorCandle] {
        var candles: [TestIndicatorCandle] = []

        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            var lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            if lines.first?.contains("open_time") == true {
                lines.removeFirst()
            }
            
            candles = lines.map { line in
                let values = line.split(separator: ",", omittingEmptySubsequences: false)
                return TestIndicatorCandle(
                    time: Int(values[0])!,
                    open: Double(values[1])!,
                    high: Double(values[2])!,
                    low: Double(values[3])!,
                    close: Double(values[4])!,
                    sma5: Double(values[5]) ?? 0.0,
                    sma7: Double(values[6]) ?? 0.0,
                    atr5: Double(values[7]) ?? 0.0,
                    atr7: Double(values[8]) ?? 0.0,
                    rsi5: Double(values[9]) ?? 0.0,
                    rsi7: Double(values[10]) ?? 0.0,
                    stoch5: Double(values[11]) ?? 0.0,
                    stoch7: Double(values[12]) ?? 0.0
                )
            }
        } catch {
            print(error)
        }

        return candles
    }

    static public func convertToCSVString<T: Encodable>(from objects: [T]) throws -> String {
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

    static public func loadAllChartFileURLs() -> [String: [URL]] {
        var result: [String: [URL]] = [:]
        let fileManager = FileManager.default
        let rootURL = URL(string: "/Users/jannicmarcon/Documents/ChartCsv")!

        do {
            let folderURLs = try fileManager.contentsOfDirectory(
                at: rootURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )

            for folderURL in folderURLs {
                guard isDirectory(folderURL),
                      !shouldSkipFolder(named: folderURL.lastPathComponent)
                else { continue }

                let csvFiles = loadCSVFiles(in: folderURL)
                if !csvFiles.isEmpty {
                    result[folderURL.lastPathComponent] = csvFiles
                }
            }
        } catch {
            print("Error: \(error)")
        }

        return result
    }

    // MARK: - Private Helpers

    private static func isDirectory(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }

    private static func shouldSkipFolder(named folderName: String) -> Bool {
        return folderName == "bak" || folderName == "tmp" || folderName == "test" || folderName == "indicatorTesting"
    }

    private static func loadCSVFiles(in folderURL: URL) -> [URL] {
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
            return fileURLs.filter { $0.pathExtension.lowercased() == "csv" }
        } catch {
            print("Failed to load files in folder \(folderURL.lastPathComponent): \(error)")
            return []
        }
    }
}

