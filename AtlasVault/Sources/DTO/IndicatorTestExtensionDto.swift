//
//  IndicatorTestExtensionDto.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 25.08.2025.
//
import GRDB

struct IndicatorTestExtensionDto: Codable, Identifiable, FetchableRecord, PersistableRecord{
    let id: Int
    let sma5: Double
    let sma7: Double
    let atr5: Double
    let atr7: Double
    let rsi5: Double
    let rsi7: Double
    let stoch5: Double
    let stoch7: Double
    let klineId: Int
    
    enum Columns{
        static let sma5 = Column(CodingKeys.sma5)
        static let sma7 = Column(CodingKeys.sma7)
        static let atr5 = Column(CodingKeys.atr5)
        static let atr7 = Column(CodingKeys.atr7)
        static let rsi5 = Column(CodingKeys.rsi5)
        static let rsi7 = Column(CodingKeys.rsi7)
        static let stoch5 = Column(CodingKeys.stoch5)
        static let stoch7 = Column(CodingKeys.stoch7)
        static let klineId = Column(CodingKeys.klineId)
    }
}
