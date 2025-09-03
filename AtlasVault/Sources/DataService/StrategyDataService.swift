//
//  StrategyDataService.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 30.08.2025.
//

import GRDB
import AtlasCore
import Foundation

public struct StrategyDataService {
    public init() { }
    
    public func getOrCreateStrategyUuid(for stratName: String, desc: String? = nil) async throws -> UUID {
        var id: UUID?
        let strategy = try await DatabaseManager.shared.read { db in
            try StrategyDto
                .filter { $0.name == stratName }
                .fetchOne(db)
        }
        id = strategy?.uuid
        
        if id == nil {
            let strat = StrategyDto(uuid: UUID(), name: stratName, description: desc)
            try await DatabaseManager.shared.write { db in
                try strat.insert(db)
                id = strat.uuid
            }
        }
        
        return id!
    }
}
