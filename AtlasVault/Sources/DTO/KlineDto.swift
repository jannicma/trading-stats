//
//  KlineDto.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 25.08.2025.
//
import GRDB

struct KlineDto: Codable, Identifiable, FetchableRecord, PersistableRecord{
    static let databaseTableName = "kline"
    
    let id: Int?
    let symbol: String
    let timeframe: Int
    let timestamp: Int
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    
    enum Columns{
        static let id = Column(CodingKeys.id)
        static let symbol = Column(CodingKeys.symbol)
        static let timeframe = Column(CodingKeys.timeframe)
        static let timestamp = Column(CodingKeys.timestamp)
        static let open = Column(CodingKeys.open)
        static let high = Column(CodingKeys.high)
        static let low = Column(CodingKeys.low)
        static let close = Column(CodingKeys.close)
        static let volume = Column(CodingKeys.volume)
    }

}
