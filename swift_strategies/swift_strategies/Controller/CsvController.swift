//
//  CsvController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//
import Foundation

struct CsvController {
    static public func getCandles(path: String) -> [Candle] {
        var candles: [Candle] = []

        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines).filter{ !$0.isEmpty }

            for line in lines {
                let fields = line.components(separatedBy: ",")
                if fields.count == 5 && fields[0] != "time" {
                    let candle = Candle( time: Int(fields[0])!,
                        open: Double(fields[1])!,
                        high: Double(fields[2])!,
                        low: Double(fields[3])!,
                        close: Double(fields[4])!
                    )

                    candles.append(candle)
                }
            }
        } catch {
            print(error)
        }

        return candles
    }
    
    
    static func getAllCharts() -> [String]{
        let dirPath = "/Users/jannicmarcon/Documents/ChartCsv"
        let fileManager = FileManager.default
        var csvFiles: [String] = []
        do {
            let files = try fileManager.contentsOfDirectory(atPath: dirPath)
            csvFiles = files.filter{$0.hasSuffix(".csv")}
                .map { dirPath + "/" + $0 }
            csvFiles = csvFiles.sorted()
        } catch {
            print("Error getting Csv files. Error: \(error)")
        }
        
        return csvFiles
    }

}
