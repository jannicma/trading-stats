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
    
    
    public init(id: UUID, symbol: String, side: Side, entryPrice: Double, entryTime: Int, entryType: FeeType, sl: Double? = nil, tp: Double? = nil, quantity: Double, open: Bool, exitPrice: Double? = nil, exitTime: Int? = nil, exitType: FeeType? = nil, exitReason: ExitReason? = nil) {
        self.id = id
        self.symbol = symbol
        self.side = side
        self.entryPrice = entryPrice
        self.entryTime = entryTime
        self.entryType = entryType
        self.sl = sl
        self.tp = tp
        self.quantity = quantity
        self.open = open
        self.exitPrice = exitPrice
        self.exitTime = exitTime
        self.exitType = exitType
        self.exitReason = exitReason
    }
}
