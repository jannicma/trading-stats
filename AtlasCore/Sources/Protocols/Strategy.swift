//
//  Strategy.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//
import Foundation

public protocol Strategy: Sendable, Codable, Identifiable, Hashable {
    var id: UUID { get }
    static var name: String { get }
    func getRequiredParameters() -> [ParameterRequirements]
    func getRequiredIndicators() -> [Indicator]
    
    init(id: UUID)

    func onCandle(
        _ chart: Chart,
        orders: [Order],
        positions: [Position],
        paramSet: ParameterSet
    ) -> [TradeAction]

}
