//
//  StrategyEvaluations.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 24.08.2025.
//

public struct StrategyEvaluations: Codable, Sendable, Hashable{
    public init(strategyName: String, evaluations: [Evaluation]) {
        self.strategyName = strategyName
        self.evaluations = evaluations
    }
    public let strategyName: String
    public var evaluations: [Evaluation]
}
