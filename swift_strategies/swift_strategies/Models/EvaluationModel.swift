//
//  EvaluationModel.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

struct EvaluationModel: Codable{
    var trades: Int
    var wins: Int
    var losses: Int
    var winRate: Double
    var riskAtrMult: Double
    var rewardAtrMult: Double
    var averageRMultiples: Double // profit/loss as a multiple of the initial risk
    var origin: String?
}
