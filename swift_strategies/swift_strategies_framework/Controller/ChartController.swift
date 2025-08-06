//
//  ChartController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

import Foundation

public struct ChartController {
    public init() { }
    private var indicatorsToCompute: [Indicator] = []

    // MARK: - Public API

    public func loadTestCharts() async -> [Chart] {
        let allChartPaths = CsvController.loadAllChartFileURLs().filter { $0.key == "test"  }
        let indicatorController = IndicatorController()
        let (name, files) = allChartPaths.first!
        
        let allCharts = generateMultiTimeframeCharts(from: files, name: name)

        var allIndicatorCharts: [Chart] = []
        for (chartName, chartCandles) in allCharts {
            var indicators = computeIndicators(for: chartCandles, using: indicatorController)
            let dropCount = indicators.map { $0.value.filter { $0 == 0.0 }.count }.max() ?? 0
            
            for (key, value) in indicators {
                indicators[key] = Array(value.dropFirst(dropCount))
            }
            let trimmedCandles = Array(chartCandles.dropFirst(dropCount))
            assert(trimmedCandles.count == indicators.first!.value.count)
            
            allIndicatorCharts.append(Chart(name: chartName, candles: trimmedCandles, indicators: indicators))
        }
        
        return allIndicatorCharts
    }

    public func loadAllCharts(initChartsForTesting: [String: [Candle]] = [:]) async -> [Chart] {
        let allChartPaths = CsvController.loadAllChartFileURLs().filter { $0.key != "bak" && $0.key != "tmp" && $0.key != "test"  }
        var allRawCharts: [String: [Candle]] = initChartsForTesting
        let indicatorController = IndicatorController()
        
        if allRawCharts.isEmpty {
            await withTaskGroup(of: [String: [Candle]].self) { group in
                for (name, files) in allChartPaths {
                    group.addTask {
                        generateMultiTimeframeCharts(from: files, name: name)
                    }
                }
                
                for await result in group {
                    allRawCharts.merge(result, uniquingKeysWith: { $1 })
                }
            }
        }

        var chartsWithIndicators: [Chart] = []
        await withTaskGroup(of: Chart.self) { group in
            for (name, candles) in allRawCharts {
                group.addTask {
                    var indicators = computeIndicators(for: candles, using: indicatorController)
                    let dropCount = indicators.map { $0.value.filter { $0 == 0.0 }.count }.max() ?? 0

                    for (key, value) in indicators {
                        indicators[key] = Array(value.dropFirst(dropCount))
                    }
                    let trimmedCandles = Array(candles.dropFirst(dropCount))
                    assert(trimmedCandles.count == indicators.first!.value.count)
                    
                    return Chart(name: name, candles: trimmedCandles, indicators: indicators)
                }
            }

            for await chart in group {
                chartsWithIndicators.append(chart)
            }
        }

        return chartsWithIndicators
    }
    
    
    public mutating func setRequiredIndicators(_ indicators: [Indicator]) {
        indicatorsToCompute = indicators
    }

    public func attemptFixAndSaveAllCharts() {
        let allChartPaths = CsvController.loadAllChartFileURLs()

        for (name, chartParts) in allChartPaths {
            var candles: [Candle] = []

            for file in chartParts {
                let part = CsvController.loadCandles(from: file)
                candles.append(contentsOf: part)
            }
            candles.sort { $0.time < $1.time }

            var lastValidIndex: Int?
            var modified = false

            for i in 0..<candles.count - 1 {
                if candleHasValidRange(candles[i]) {
                    let gap = i - (lastValidIndex ?? 0)
                    if gap > 1 {
                        interpolateInvalidCandles(in: &candles, from: lastValidIndex!, to: i)
                        modified = true
                    }
                    lastValidIndex = i
                }
            }

            if modified {
                if isValidChart(candles) {
                    do {
                        try saveChartGroupedByMonth(candles, named: name)
                    } catch {
                        print("there was an error")
                    }
                } else {
                    print("maaan, it did not fix it...")
                }
            }
        }
    }

    // MARK: - Private Helper Methods

    private func isValidChart(_ chart: [Candle]) -> Bool {
        var firstTimeDiff: Int = 0
        var lastTime: Int = 0

        for candle in chart {
            if firstTimeDiff > 0 {
                if lastTime + firstTimeDiff != candle.time {
                    return false
                }
            } else if lastTime > 0 {
                firstTimeDiff = candle.time - lastTime
            }

            if candle.high == candle.low {
                return false
            }

            lastTime = candle.time
        }

        return true
    }

    private func computeIndicators(for chart: [Candle], using controller: IndicatorController) -> [String: [Double]] {
        return controller.computeIndicators(for: chart, requiredIndicators: indicatorsToCompute)
    }

    private func generateMultiTimeframeCharts(from files: [URL], name: String) -> [String: [Candle]] {
        var candles: [Candle] = []
        for url in files {
            let part = CsvController.loadCandles(from: url)
            candles.append(contentsOf: part)
        }

        candles.sort { $0.time < $1.time }
        assert(isValidChart(candles), "There is a gap in the chart")

        let variations = ["3m": 3, "5m": 5, "15m": 15, "30m": 30]
        var result: [String: [Candle]] = [name + "_1m": candles]

        for (label, groupSize) in variations {
            var grouped: [Candle] = []
            var buffer: [Candle] = []

            for candle in candles {
                buffer.append(candle)
                if buffer.count == groupSize {
                    grouped.append(Candle(
                        time: buffer.first!.time,
                        open: buffer.first!.open,
                        high: buffer.map(\.high).max()!,
                        low: buffer.map(\.low).min()!,
                        close: buffer.last!.close
                    ))
                    buffer.removeAll()
                }
            }

            assert(isValidChart(grouped), "There is a gap in the \(label) chart")
            result[name + "_\(label)"] = grouped
        }

        return result
    }

    private func saveChartGroupedByMonth(_ chart: [Candle], named name: String) throws {
        var grouped: [String: [Candle]] = [:]

        for candle in chart {
            guard let (year, month) = TimeController.getYearAndMonth(from: candle.time) else {
                throw NSError(domain: "Invalid timestamp", code: 0, userInfo: nil)
            }

            let paddedMonth = String(format: "%02d", month)
            let fileName = "\(name)-\(year)-\(paddedMonth)"
            grouped[fileName, default: []].append(candle)
        }

        let basePath = "/Users/jannicmarcon/Documents/ChartCsv"
        let folderPath = "\(basePath)/\(name)_new"

        for (file, chartPart) in grouped {
            let path = "\(folderPath)/\(file).csv"
            do {
                let csv = try CsvController.convertToCSVString(from: chartPart)
                try csv.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
            } catch {
                print("error on saving file: \(error)")
            }
        }
    }

    private func interpolateInvalidCandles(in candles: inout [Candle], from start: Int, to end: Int) {
        let previous = candles[start]
        let next = candles[end]
        let count = end - start
        let totalMovement = next.close - previous.close
        let avgMove = totalMovement / Double(count)
        let wickSize = abs(avgMove) / 4

        for i in (start + 1)...end {
            let open = candles[i - 1].close
            if i != end {
                candles[i].close = open + avgMove
            }
            candles[i].open = open
            candles[i].high = max(open, open + avgMove) + wickSize
            candles[i].low = min(open, open + avgMove) - wickSize
        }
    }

    private func candleHasValidRange(_ candle: Candle) -> Bool {
        return candle.high > candle.low
    }
}
