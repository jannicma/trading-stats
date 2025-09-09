import Foundation

public struct Position {
    public let id: UUID
    public let symbol: String
    public let side: Side
    public let entryPrice: Double
    public let entryTime: Int
    public let entryType: FeeType
    public var sl: Double?
    public var tp: Double?
    public let quantity: Double
    public var open: Bool
    public var exitPrice: Double?
    public var exitTime: Int?
    public var exitType: FeeType?
    public var exitReason: ExitReason?
}
