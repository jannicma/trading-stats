//
//  BacktestEquityDto.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 25.08.2025.
//
import GRDB

struct BacktestEquityDto: Codable, Identifiable, FetchableRecord, PersistableRecord{
    static let databaseTableName = "backtestEquity"
    
    let id: Int
    let tradeNumber: Int
    let equity: Double
    let evaluationId: Int
    
    enum Columns{
        static let tradeNumber = Column(CodingKeys.tradeNumber)
        static let equity = Column(CodingKeys.equity)
        static let evaluationId = Column(CodingKeys.evaluationId)
    }
}
