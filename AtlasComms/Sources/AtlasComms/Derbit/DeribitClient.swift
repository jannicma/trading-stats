import AtlasCore
import AtlasKit
import Foundation

public actor DeribitClient: ExchangeClient {
    private var charts: [Chart] = []
    private let pub: DeribitPublicWs = DeribitPublicWs()
    private var candleTask: Task<Void, Never>?
    private var chartIndicators: [Indicator] = []
    private var chartService: ChartService
    private let baseUrl: URL = URL(string: "wss://www.deribit.com/ws/api/v2")!

    public init() {
        chartService = ChartService(indicatorsToCompute: [])
        Task {
            await self.initWebSockets()
        }
    }
    
    public func addRequiredIndicator(_ indicator: Indicator) {
        //TODO: only add to charts where needed, when needed
        chartService.addRequiredIndicators(indicator: indicator)
        for idx in charts.indices {
            chartService.addIndicatorsToChart(&charts[idx])
        }
    }

    public func fetchChart(of chartName: String, timeframe: Int) -> Chart? {
        return charts.first { $0.name == chartName && $0.timeframe == timeframe }
    }

    public func initWebSockets() async {
        do {
            try await pub.connect(url: baseUrl)
        } catch {
            print("abc")
        }
    }

    public func startChartRefresh(symbols: [String], timeframes: [Int]) async {
        await backloadCharts(symbols: symbols, timeframes: timeframes)

        for symbol in symbols {
            for timeframe in timeframes {
                await handleChartUpdate(symbol: symbol, tf: timeframe)
            }
        }
    }

    private func handleChartUpdate(symbol: String, tf: Int) async {
        let chartStream = try? await pub.subscribeChart(symbol: symbol, resolution: tf)
        guard let stream = chartStream else { return }
        Task {
            do {
                for try await kline in stream {
                    let chartName = kline.symbol
                    let timeframe = kline.resolution
                    print("New Data on \(chartName) at \(kline.time) with resolution \(timeframe)")
                    let candle = Candle(
                        time: kline.time,
                        open: (kline.open as NSDecimalNumber).doubleValue,
                        high: (kline.high as NSDecimalNumber).doubleValue,
                        low: (kline.low as NSDecimalNumber).doubleValue,
                        close: (kline.close as NSDecimalNumber).doubleValue,
                        volume: (kline.volume as NSDecimalNumber).doubleValue
                    )
                    await self.updateChart(
                        symbol: chartName, timeframe: timeframe, newCandle: candle)
                }
            } catch {
                print("aaa")
            }
        }
    }

    private func updateChart(symbol: String, timeframe: Int, newCandle: Candle) async {
        guard
            let chartIndex = charts.firstIndex(where: {
                $0.name == symbol && $0.timeframe == timeframe
            })
        else {
            print("asijudhai")
            return
        }
        let lastCandleIndex = charts[chartIndex].candles.count - 1
        let lastCandleTime = charts[chartIndex].candles[lastCandleIndex].time
        if lastCandleTime == newCandle.time {
            charts[chartIndex].candles[lastCandleIndex] = newCandle
        } else {
            if charts[chartIndex].candles.count > 1500 {
                _ = charts[chartIndex].candles.removeFirst()
            }
            charts[chartIndex].candles.append(newCandle)
        }
        chartService.updateLastIndicators(&charts[chartIndex])
    }

    private func backloadCharts(symbols: [String], timeframes: [Int]) async {
        for symbol in symbols {
            for timeframe in timeframes {
                var chartCandles: [Candle] = []
                do {
                    chartCandles = try await backloadCandles(symbol: symbol, timeframe: timeframe)
                } catch {
                    print("error on loading candles with rest: \(error)")
                }
                var chart = Chart(name: symbol, timeframe: timeframe, candles: chartCandles)
                chartService.addIndicatorsToChart(&chart)
                charts.append(chart)
            }
        }
    }

    private func backloadCandles(symbol: String, timeframe: Int) async throws -> [Candle] {
        return await DeribitPublicRest.getHistoricalChart(
            for: symbol, intervalMinutes: timeframe, limit: 1000)
    }
}
