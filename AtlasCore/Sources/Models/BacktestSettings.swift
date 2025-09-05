//
//  SimulatedFees.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 05.09.2025.
//

public struct BacktestSettings: Sendable {
    public init(fees: SimulatedFees) {
        self.fees = fees
    }
    public var fees: SimulatedFees
    //later add Parameter ranges
}


public struct SimulatedFees: Sendable {
    public init(makerFee: Double, takerFee: Double) {
        self.makerFee = makerFee
        self.takerFee = takerFee
    }
    
    public var makerFee: Double
    public var takerFee: Double

}
