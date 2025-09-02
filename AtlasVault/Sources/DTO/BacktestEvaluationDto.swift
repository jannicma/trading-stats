//
//  BacktestEvaluationDto.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 25.08.2025.
//
import GRDB
import Foundation
import AtlasCore

struct BacktestEvaluationDto: Codable, Identifiable, FetchableRecord, MutablePersistableRecord{
    static let databaseTableName = "backtestEvaluation"

    var id: Int64? = nil
    let strategyUuid: UUID
    let asset: String
    let timeframe: Int
    let parameters: ParameterSet?
    let trades: Int
    let wins: Int
    let losses: Int
    let winRate: Double
    let averageRMultiples: Double
    let expectancy: Double
    let avgRRR: Double
    let sharpe: Double
    let sortino: Double
    let maxDrawdown: Double
    let calmarRatio: Double
    let profitFactor: Double
    let ulcerIndex: Double
    let recoveryFactor: Double
    let equityVariance: Double
    let returnSpread50: Double
    
    
    enum Columns{
        static let id = Column(CodingKeys.id)
        static let strategyUuid = Column(CodingKeys.strategyUuid)
        static let asset = Column(CodingKeys.asset)
        static let timeframe = Column(CodingKeys.timeframe)
        static let parameters = Column(CodingKeys.parameters)
        static let trades = Column(CodingKeys.trades)
        static let wins = Column(CodingKeys.wins)
        static let losses = Column(CodingKeys.losses)
        static let winRate = Column(CodingKeys.winRate)
        static let averageRMultiples = Column(CodingKeys.averageRMultiples)
        static let expectancy = Column(CodingKeys.expectancy)
        static let avgRRR = Column(CodingKeys.avgRRR)
        static let sharpe = Column(CodingKeys.sharpe)
        static let sortino = Column(CodingKeys.sortino)
        static let maxDrawdown = Column(CodingKeys.maxDrawdown)
        static let calmarRatio = Column(CodingKeys.calmarRatio)
        static let profitFactor = Column(CodingKeys.profitFactor)
        static let ulcerIndex = Column(CodingKeys.ulcerIndex)
        static let recoveryFactor = Column(CodingKeys.recoveryFactor)
        static let equityVariance = Column(CodingKeys.equityVariance)
        static let returnSpread50 = Column(CodingKeys.returnSpread50)
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
        
    public func toEvaluation() -> Evaluation {
        Evaluation(id: Int(self.id!), timeframe: self.timeframe, symbol: self.asset, paramSet: self.parameters, trades: self.trades, wins: self.wins, losses: self.losses, winRate: self.winRate, averageRMultiples: self.averageRMultiples, expectancy: self.expectancy, avgRRR: self.avgRRR, sharpe: self.sharpe, sortino: self.sortino, maxDrawdown: self.maxDrawdown, calmarRatio: self.calmarRatio, profitFactor: self.profitFactor, ulcerIndex: self.ulcerIndex, recoveryFactor: self.recoveryFactor, equityVariance: self.equityVariance, returnSpread50: self.returnSpread50)
    }
}
