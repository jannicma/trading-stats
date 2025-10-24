//
//  LiveStrategyOverview.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 20.10.2025.
//
import Foundation

public struct LiveStrategyOverview: Sendable, Codable, Identifiable, Hashable {
    public init(id: UUID, name: String, parameters: ParameterSet, pnl: Double) {
        self.id = id
        self.name = name
        self.parameters = parameters
        self.pnl = pnl
    }
    
    public var id: UUID
    public var name: String
    public var parameters: ParameterSet
    public var pnl: Double // to be refinded
}
