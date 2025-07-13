//
//  EvaluationController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

struct EvaluationController{
    func evaluateEvaluations(evaluations: [EvaluationModel]){
        var evals = evaluations
        evals.sort(by: { $0.winLossRatio > $1.winLossRatio })
        
        for i in 0...5{
            print("Rank \(i+1): \(evals[i].origin ?? "unknown")")
            printEvaluation(evals[i])
            print("\n")
        }
    }
    
    
    func evaluateTrades(simulatedTrades: [SimulatedTrade], printEval: Bool = false) -> EvaluationModel {
        var evaluation = EvaluationModel(trades: 0, wins: 0, losses: 0, winLossRatio: 0.0)
        
        evaluation.trades = simulatedTrades.count
        evaluation.wins = simulatedTrades.filter { $0.exitPrice == $0.tpPrice }.count
        evaluation.losses = simulatedTrades.filter { $0.exitPrice == $0.slPrice}.count
        evaluation.winLossRatio = Double(evaluation.wins) / Double(evaluation.trades)
        
        assert(evaluation.trades == evaluation.wins + evaluation.losses, "evaluation trades do not count up correctly")
        
        if printEval { printEvaluation(evaluation) }
        return evaluation
    }
    
    private func printEvaluation(_ evaluation: EvaluationModel) {
        print("Total Trades: \(evaluation.trades)")
        print("Wins: \(evaluation.wins)")
        print("Losses: \(evaluation.losses)")
        print("Win Loss Ratio: \(evaluation.winLossRatio)")
    }
}
