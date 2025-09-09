import Foundation

public struct Order {
    public let id: UUID
    public let side: Side
    public let type: OrderType
    public let quantity: Double
    public var sl: Double
    public var tp: Double
    public let entryType: FeeType
}
