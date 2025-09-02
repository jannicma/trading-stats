//
//  EvaluationDataService.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 30.08.2025.
//

import AtlasCore
import GRDB
import Foundation

public struct EvaluationDataService {
    public init () { }
    
    public func saveEvaluations(_ evaluations: [Evaluation], strategy: UUID) async -> Bool {
        var evaluationDtos: [BacktestEvaluationDto] = evaluations.map{ eval in
            BacktestEvaluationDto(strategyUuid: strategy, asset: eval.symbol!, timeframe: eval.timeframe!, parameters: eval.paramSet, trades: eval.trades, wins: eval.wins, losses: eval.losses, winRate: eval.winRate, averageRMultiples: eval.averageRMultiples, expectancy: eval.expectancy, avgRRR: eval.avgRRR, sharpe: eval.sharpe, sortino: eval.sortino, maxDrawdown: eval.maxDrawdown, calmarRatio: eval.calmarRatio, profitFactor: eval.profitFactor, ulcerIndex: eval.ulcerIndex, recoveryFactor: eval.recoveryFactor, equityVariance: eval.equityVariance, returnSpread50: eval.returnSpread50)
        }
        
        do {
            try await DatabaseManager.shared.write { db in
                try BacktestEvaluationDto
                    .filter{ $0.strategyUuid == strategy }
                    .deleteAll(db)
                
                for idx in evaluationDtos.indices {
                    do{
                        try evaluationDtos[idx].insert(db)
                    } catch {
                        print("error at index: \(idx)")
                    }
                }

                // Build equity lines now that evaluation ids are available
                var equityLines: [BacktestEquityDto] = []
                for (i, dtoEvaluation) in evaluationDtos.enumerated() {
                    let originalEvaluation = evaluations[i]
                    guard let evalId = dtoEvaluation.id else {
                        print("could not insert evaluation")
                        continue
                    }

                    let points: [BacktestEquityDto] = originalEvaluation.equityCurve.map { point in
                        BacktestEquityDto(tradeNumber: point.step, equity: point.equity, evaluationId: evalId)
                    }

                    equityLines.append(contentsOf: points)
                }

                // Persist equity lines in the same transaction
                for equityLine in equityLines {
                    try equityLine.insert(db)
                }
            }
        } catch {
            print("some error happened on eval entry save... \(error)")
            return false
        }


        
        return true
        
    }
    
    
    public func getAllEvaluations(for strategy: UUID) async throws -> [Evaluation] {
        let evalDtos = try await DatabaseManager.shared.read { db in
            try BacktestEvaluationDto
                .filter{ $0.strategyUuid == strategy }
                .fetchAll(db)
        }
        
        let evaluations = evalDtos.map { $0.toEvaluation() }
        
        return evaluations
    }
    
    
    public func getEquityCurve(of backtestRunId: Int) async throws -> [EquityPoint] {
        let backtestEquityDtos = try await DatabaseManager.shared.read { db in
            try BacktestEquityDto
                .filter{ $0.evaluationId == backtestRunId }
                .fetchAll(db)
        }
        
        let equityPoints = backtestEquityDtos.map { $0.toEquityPoint() }
        
        return equityPoints
    }
}
