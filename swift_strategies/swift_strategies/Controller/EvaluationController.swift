//
//  EvaluationController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

struct EvaluationController{
    func evaluateEvaluations(evaluations: [EvaluationModel]){
        var evals = evaluations
        
        for i in 0...5{
            print("Rank \(i+1): \(evals[i].origin ?? "unknown")")
            printEvaluation(evals[i])
            print("\n")
        }
    }
    
    
    func evaluateTrades(simulatedTrades: [SimulatedTrade], risk: Double, reward: Double, printEval: Bool = false) -> EvaluationModel {
        var evaluation = EvaluationModel(trades: 0, wins: 0, losses: 0, winRate: 0.0, riskAtrMult: risk, rewardAtrMult: reward, averageRMultiples: 0.0)
        
        evaluation.trades = simulatedTrades.count
        evaluation.wins = simulatedTrades.filter { $0.exitPrice == $0.tpPrice }.count
        evaluation.losses = simulatedTrades.filter { $0.exitPrice == $0.slPrice}.count
        evaluation.winRate = (Double(evaluation.wins) / Double(evaluation.trades)) * 100
        
        var allRealizedR: [Double] = []
        for trade in simulatedTrades {
            let isLong = trade.slPrice < trade.entryPrice
            let slDiff = abs(trade.entryPrice - trade.slPrice)
            let exitDiff = isLong ? trade.exitPrice! - trade.entryPrice : trade.entryPrice - trade.exitPrice!
            
            let realizedR = exitDiff / slDiff
            allRealizedR.append(realizedR)
        }
        let sumR = allRealizedR.reduce(0, +)
        evaluation.averageRMultiples = sumR / Double(allRealizedR.count)

        assert(evaluation.trades == evaluation.wins + evaluation.losses, "evaluation trades do not count up correctly")
        
        if printEval { printEvaluation(evaluation) }
        return evaluation
    }
    
    private func printEvaluation(_ evaluation: EvaluationModel) {
        print("Total Trades: \(evaluation.trades)")
        print("Wins: \(evaluation.wins)")
        print("Losses: \(evaluation.losses)")
        print("Win Rate: \(evaluation.winRate)")
        print("ATR Risk: \(evaluation.riskAtrMult)")
        print("ATR Reward: \(evaluation.rewardAtrMult)")
        print("Average R Multiples: \(evaluation.averageRMultiples)")
    }
}
