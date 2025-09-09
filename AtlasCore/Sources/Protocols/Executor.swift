public protocol Executor {
    func onCandle(
        _ chart: [Chart],
        openOrders: [Order],
        positions: [Position]
    ) -> [TradeAction]
}
