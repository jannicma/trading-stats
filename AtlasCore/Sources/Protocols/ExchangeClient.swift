public protocol ExchangeClient {
    func fetchChart(of: String, timeframe: Int) -> [Chart]
}
