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
        var firstTimeGap: Int = 0
        var lastTime: Int = 0
        for candle in chart {
            if firstTimeGap > 0 {
                if lastTime + firstTimeGap != candle.time {
                    return false
                }
            }
            else{
                if lastTime > 0{
                    firstTimeGap = candle.time - lastTime
                }
            }
            
            if candle.high == candle.low {
                return false
            }
            
            lastTime = candle.time
        }
        
        return true
    }
    
    
    private func getChartWithIndicaors(filepaths: [URL], indicatorController: IndicatorController) -> [IndicatorCandle] {
        var candles: [Candle] = []
        for chartPart in filepaths {
            let part = CsvController.getCandles(path: chartPart)
            candles.append(contentsOf: part)
        }
        candles.sort { $0.time < $1.time }
        assert(validateChart(chart: candles), "There is a gap in the chart")
        
        return indicatorController.addIndicators(candles: candles, "sma200", "sma20", "sma5", "atr")
    }
    
    
    public func getAllChartsWithIndicaors() async -> [String: [IndicatorCandle]] {
        let allChartPaths = CsvController.getAllCharts().filter { $0.key != "bak" && $0.key != "tmp"  }
        var allCharts: [String: [IndicatorCandle]] = [:]
        
        let indicatorController = IndicatorController()
        
        await withTaskGroup(of: (String, [IndicatorCandle]).self) { group in
            for (name, files) in allChartPaths {
                group.addTask {
                    return (name, getChartWithIndicaors(filepaths: files, indicatorController: indicatorController))
                }
            }

            for await (name, data) in group {
                allCharts[name] = data
            }
        }

        return allCharts
    }
    
    
    public func fixCharts(){
        let allChartPaths = CsvController.getAllCharts().filter { $0.key != "bak" && $0.key != "tmp"  }
        
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
                do{
                    try saveChartMonthly(chart: candles, name: name)
                }catch{
                    print("there was an error")
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
            
            let filename = "\(name)-\(year)-\(month)"
            groupedCandles[filename] = (groupedCandles[filename] ?? []) + [candle]
        }
        
        //TODO: save file
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
            
            candles[i].open = open
            candles[i].close = open + avgMovement
            candles[i].high = max(open, open+avgMovement) + wickSize
            candles[i].low = min(open, open+avgMovement) - wickSize
        }
    }
    
    private func isValidCandle(_ candle: Candle) -> Bool {
        return candle.high > candle.low
    }
}
