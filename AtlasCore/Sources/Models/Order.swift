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
}
