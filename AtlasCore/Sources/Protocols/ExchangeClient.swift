public protocol ExchangeClient: Actor  {
    func fetchChart(of: String, timeframe: Int) -> Chart?
    func startChartRefresh(symbols: [String], timeframes: [Int]) async
    func initWebSockets() async
    func addRequiredIndicator(_ indicator: Indicator)

    //for later: order endpoints like place or modify
}
