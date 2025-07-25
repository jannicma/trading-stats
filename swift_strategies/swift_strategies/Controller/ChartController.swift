//
//  ChartController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 14.07.2025.
//
import Foundation

struct ChartController {
    private func validateChart(chart: [Candle]) -> Bool {
        //check for gaps in the candles
        var firstTimeDiff: Int = 0
        var lastTime: Int = 0
        for candle in chart {
            if firstTimeDiff > 0 {
                if lastTime + firstTimeDiff != candle.time {
                    return false
                }
            }
            else{
                if lastTime > 0{
                    firstTimeDiff = candle.time - lastTime
                }
            }
            
            if candle.high == candle.low {
                return false
            }
            
            lastTime = candle.time
        }
        
        return true
    }
    
    
    private func getChartWithIndicaors(chart: [Candle], indicatorController: IndicatorController) -> [IndicatorCandle] {
        return indicatorController.addIndicators(candles: chart, "sma200", "sma20", "sma5", "atr")
    }
    
    
    private func getChartsInAllTimeframes(name: String, files: [URL]) -> [String: [Candle]] {
        var candles: [Candle] = []
        for chartPart in files {
            let part = CsvController.getCandles(path: chartPart)
            candles.append(contentsOf: part)
        }
        candles.sort { $0.time < $1.time }
        assert(validateChart(chart: candles), "There is a gap in the chart")
        
        let allNewVariations = ["3m": 3,
                                "5m": 5,
                                "15m": 15,
                                "30m": 30]
        var finalCandles: [String: [Candle]] = [name+"_1m": candles]
        
        for (timeframeName, candleCount) in allNewVariations{
            var result: [Candle] = []
            var buffer: [Candle] = []

            for candle in candles {
                buffer.append(candle)
                if buffer.count == candleCount {
                    result.append(Candle(
                        time: buffer.first!.time,
                        open: buffer.first!.open,
                        high: buffer.map(\.high).max()!,
                        low: buffer.map(\.low).min()!,
                        close: buffer.last!.close
                    ))
                    buffer.removeAll()
                }
            }
            assert(validateChart(chart: result), "There is a gap in the chart")
            finalCandles[name+"_\(timeframeName)"] = result
        }
        
        return finalCandles
    }
    
    public func getAllChartsWithIndicaors() async -> [String: [IndicatorCandle]] {
        let allChartPaths = CsvController.getAllCharts().filter { $0.key != "bak" && $0.key != "tmp"  }
        var allCharts: [String: [Candle]] = [:]
        
        let indicatorController = IndicatorController()
        
        //generate/load all charts
        await withTaskGroup(of: [String: [Candle]].self) { group in
            for (name, files) in allChartPaths {
                group.addTask {
                    return getChartsInAllTimeframes(name: name, files: files)
                }
            }

            for await data in group {
                allCharts.merge(data, uniquingKeysWith: { $1 })
            }
        }
        
        var allIndicatorCharts: [String: [IndicatorCandle]] = [:]
        //add indicators to charts
        await withTaskGroup(of: (String, [IndicatorCandle]).self) { group in
            for (name, chart) in allCharts {
                group.addTask {
                    return (name, getChartWithIndicaors(chart: chart, indicatorController: indicatorController))
                }
            }

            for await (chartName, indicatorCandlesChart) in group {
                allIndicatorCharts[chartName] = indicatorCandlesChart
            }
        }

        return allIndicatorCharts
    }
    
    
    public func fixCharts(){
        let allChartPaths = CsvController.getAllCharts()
        
        for (name, chartParts) in allChartPaths {
            var candles: [Candle] = []

            for file in chartParts {
                let part = CsvController.getCandles(path: file)
                candles.append(contentsOf: part)
            }
            candles.sort { $0.time < $1.time }

            var lastCorrectCloseIndex: Int?
            var didChange = false
            for i in 0..<candles.count-1 {
                if isValidCandle(candles[i]) {
                    let indexDifference = i - (lastCorrectCloseIndex ?? 0)
                    if indexDifference > 1 {
                        fixCandles(candles: &candles, startIndex: lastCorrectCloseIndex!, endIndex: i)
                        didChange = true
                    }
                    lastCorrectCloseIndex = i
                }
            }
            
            if didChange {
                if validateChart(chart: candles){
                    do{
                        try saveChartMonthly(chart: candles, name: name)
                    }catch{
                        print("there was an error")
                    }
                }else{
                    print("maaan, it did not fix it...")
                }
            }
        }
    }
    
    private func saveChartMonthly(chart: [Candle], name: String) throws {
        var groupedCandles: [String: [Candle]] = [:]
        
        for candle in chart{
            guard let (year, month) = TimeController.getYearAndMonth(from: candle.time) else{
                throw NSError(domain: "Some invalid timestamp", code: 0, userInfo: nil)
            }
            
            let paddedMonth = "\(month < 10 ? "0" : "")\(month)"
            let filename = "\(name)-\(year)-\(paddedMonth)"
            groupedCandles[filename] = (groupedCandles[filename] ?? []) + [candle]
        }
        
        let basePath = "/Users/jannicmarcon/Documents/ChartCsv"
        let folderPath = "\(basePath)/\(name)_new"
        
        for (fileToSave, chartPart) in groupedCandles {
            let filepath = "\(folderPath)/\(fileToSave).csv"
            do{
                let csvString = try CsvController.convertToCSV(chartPart)
                let url = URL(fileURLWithPath: filepath)
                try csvString.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                print("error on saving file: \(error)")
            }
        }
    }
    
    private func fixCandles(candles: inout [Candle], startIndex: Int, endIndex: Int){
        let prevCandle = candles[startIndex]
        let nextCandle = candles[endIndex]
        let countFaultyCandles = endIndex - startIndex
        
        let movement = nextCandle.close - prevCandle.close
        let avgMovement = movement / Double(countFaultyCandles)
        let wickSize = abs(avgMovement) / 4
        
        for i in startIndex+1...endIndex {
            let open = candles[i-1].close
            
            if i != endIndex{
                candles[i].close = open + avgMovement
            }
            candles[i].open = open
            candles[i].high = max(open, open+avgMovement) + wickSize
            candles[i].low = min(open, open+avgMovement) - wickSize
        }
    }
    
    private func isValidCandle(_ candle: Candle) -> Bool {
        return candle.high > candle.low
    }
}
