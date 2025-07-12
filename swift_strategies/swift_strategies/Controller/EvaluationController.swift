//
//  EvaluationController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

struct EvaluationController{
    func evaluate(simulatedTrades: [SimulatedTrade]) {
        var evaluation = EvaluationModel(trades: 0, wins: 0, losses: 0)
        
        evaluation.trades = simulatedTrades.count
        evaluation.wins = simulatedTrades.filter { $0.exitPrice == $0.tpPrice }.count
        evaluation.losses = simulatedTrades.filter { $0.exitPrice == $0.slPrice}.count
        
        assert(evaluation.trades == evaluation.wins + evaluation.losses, "evaluation trades do not count up correctly")
        
        printEvaluation(evaluation)
    }
    
    private func printEvaluation(_ evaluation: EvaluationModel) {
        print("Total Trades: \(evaluation.trades)")
        print("Wins: \(evaluation.wins)")
        print("Losses: \(evaluation.losses)")
    }
}
