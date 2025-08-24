//
//  StrategyEvaluations.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 24.08.2025.
//

public struct StrategyEvaluations: Codable, Sendable, Hashable{
    public let strategyName: String
    public let evaluations: [Evaluation]
}
