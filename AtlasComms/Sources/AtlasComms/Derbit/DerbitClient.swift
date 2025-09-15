import AtlasCore
import AtlasKit
import Foundation

public actor DerbitClient: ExchangeClient {
    private var charts: [Chart] = []
    // private pub: DerbitPublicWs = DerbitPublicWs()
    private var candleTask: Task<Void, Never>?
    private let indicatorEngine: IndicatorEngine = .init()
    private var chartIndicators: [Indicator] = []

    public func fetchChart(of chartName: String, timeframe: Int) -> Chart {
        return charts.first { $0.name == chartName && $0.timeframe == timeframe }
    }

    public func initWebSockets() async {
        pub.connect()
    }

    public func startChartRefresh(symbols: [String], timeframes: [Int]) async {
        await backloadCharts(sybols: symbols, timeframes: timeframes)
    }

    private func backloadCharts(sybols: [String], timeframes: [Int]) {
        for symbol in symbols {
            for timeframe in timeframes {
                var chartCandles: [Candle]
                do {
                    chartCandles = await backloadCandles(symbol: symbol, timeframe: timeframe)
                } catch {
                    print("error on loading candles with rest: \(error)")
                }
                let chart = indicatorEngine.computeIndicators(
                    for: chartCandles, requiredIndicators: chartIndicators)
                charts.append(chart)
            }
        }
    }

    private func backloadCandles(symbol: String, timeframe: Int) async throws -> [Candle] {
        //return candles with rest call
    }
}
