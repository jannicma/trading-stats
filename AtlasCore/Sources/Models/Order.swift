import Foundation

public struct Order {
    public let id: UUID
    public let symbol: String
    public let side: Side
    public var type: OrderType
    public var quantity: Double
    public var sl: Double
    public var tp: Double
    public let entryType: FeeType

    public init(id: UUID, symbol: String, side: Side, type: OrderType, quantity: Double, sl: Double, tp: Double, entryType: FeeType) {
        self.id = id
        self.symbol = symbol
        self.side = side
        self.type = type
        self.quantity = quantity
        self.sl = sl
        self.tp = tp
        self.entryType = entryType
    }
}
