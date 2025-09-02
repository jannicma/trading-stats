//
//  StrategyEvaluations.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 24.08.2025.
//
import Foundation

public struct StrategyEvaluations: Codable, Sendable, Hashable{
    public init(strategyName: String, strategyId: UUID?, evaluations: [Evaluation]) {
        self.strategyName = strategyName
        self.strategyId = strategyId
        self.evaluations = evaluations
    }
    public let strategyName: String
    public let strategyId: UUID?
    public var evaluations: [Evaluation]
}
