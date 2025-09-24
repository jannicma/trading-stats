public enum OrderType: Sendable {
    case market
    case limit(price: Double)
    
    public var isLimit: Bool {
        if case .limit = self { return true }
        return false
    }
}
