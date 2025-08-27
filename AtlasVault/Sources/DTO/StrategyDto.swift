//
//  StrategyDto.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 25.08.2025.
//
import GRDB
import Foundation

struct StrategyDto: Codable, Identifiable, FetchableRecord, PersistableRecord{
    static let databaseTableName = "strategy"

    let id: Int
    let uuid: UUID
    let name: String
    let description: String?
    
    enum Columns{
        static let uuid = Column(CodingKeys.uuid)
        static let name = Column(CodingKeys.name)
        static let description = Column(CodingKeys.description)
    }
}
