public protocol Executor {
    mutating func submit(_ actions: [TradeAction], marketPrice: Double?, time: Int?) async // market price is used in backtest executor
    func getOpenOrders() async -> [Order]
    func getOpenPositions() async -> [Position]
    func getAllClosedPositions() async -> [Position]
}
