public protocol ExchangeClient {
    func fetchChart(of: String, timeframe: Int) -> [Chart]
    func startChartRefresh(symbols: [String], timeframes: [Int]) async
    func initWebSockets() async

    //for later: order endpoints like place or modify
}
