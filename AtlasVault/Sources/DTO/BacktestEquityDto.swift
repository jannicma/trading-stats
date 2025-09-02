//
//  BacktestEquityDto.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 25.08.2025.
//
import GRDB
import AtlasCore

struct BacktestEquityDto: Codable, Identifiable, FetchableRecord, PersistableRecord{
    static let databaseTableName = "backtestEquity"
    
    var id: Int? = nil
    let tradeNumber: Int
    let equity: Double
    let evaluationId: Int64
    
    enum Columns{
        static let tradeNumber = Column(CodingKeys.tradeNumber)
        static let equity = Column(CodingKeys.equity)
        static let evaluationId = Column(CodingKeys.evaluationId)
    }
    
    public func toEquityPoint() -> EquityPoint {
        EquityPoint(step: self.tradeNumber, equity: self.equity)
    }
}
