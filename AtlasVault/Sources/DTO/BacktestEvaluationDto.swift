//
//  BacktestEvaluationDto.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 25.08.2025.
//
import GRDB
import Foundation
import AtlasCore

struct BacktestEvaluationDto: Codable, Identifiable, FetchableRecord, PersistableRecord{
    static let databaseTableName = "backtestEvaluation"

    let id: Int
    let strategyUuid: UUID
    let asset: String
    let timeframe: Int
    let parameters: ParameterSet?
    let trades: Int
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
    let revcoveryFactor: Double
    let equityVariance: Double
    let returnSpread50: Double
    
    
    enum Columns{
        static let strategyUuid = Column(CodingKeys.strategyUuid)
        static let asset = Column(CodingKeys.asset)
        static let timeframe = Column(CodingKeys.timeframe)
        static let parameters = Column(CodingKeys.parameters)
        static let trades = Column(CodingKeys.trades)
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
        static let revcoveryFactor = Column(CodingKeys.revcoveryFactor)
        static let equityVariance = Column(CodingKeys.equityVariance)
        static let returnSpread50 = Column(CodingKeys.returnSpread50)
    }

}
