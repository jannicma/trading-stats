public struct PositionUpdate {
    public let newSL: Double?
    public let newTP: Double?

    public init(newSL: Double?, newTP: Double?) {
        self.newSL = newSL
        self.newTP = newTP
    }
}
