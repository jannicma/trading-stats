//
//  DatabaseManager.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 24.08.2025.
//
import GRDB

public actor DatabaseManager {
    static let shared = try! DatabaseManager()

    private let dbPool: DatabasePool

    private init() throws {
        let url = try DBPaths.databaseURL(appName: "TradeJournal")
        var config = Configuration()
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA foreign_keys = ON;")
            try db.execute(sql: "PRAGMA journal_mode = WAL;")
        }
        dbPool = try DatabasePool(path: url.path, configuration: config)
        try Self.makeMigrator().migrate(dbPool)
    }

    // Schema migrations live here:
    private static func makeMigrator() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()

        // Initial schema
        migrator.registerMigration("v1") { db in
            try db.create(table: "kline") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("symbol", .text).notNull()
                t.column("timeframe", .integer).notNull()
                t.column("timestamp", .integer).notNull()
                t.column("open", .double).notNull()
                t.column("high", .double).notNull()
                t.column("low", .double).notNull()
                t.column("close", .double).notNull()
                t.column("volume", .double).notNull().defaults(to: 0)
                
                t.uniqueKey(["symbol", "timeframe", "timestamp"])
            }
            try db.create(index: "kline_symbol_timeframe_idx", on: "kline", columns: ["symbol", "timeframe"])
            
            try db.create(table: "strategy") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("uuid", .text).notNull()
                t.column("name", .text).notNull()
                t.column("description", .text)
            }
            
            try db.create(table: "backtestEvaluation") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("strategyUuid", .text).notNull()
                t.column("asset", .text).notNull()
                t.column("timeframe", .integer).notNull()
                t.column("parameters", .text)
                t.column("trades", .integer).notNull()
                t.column("wins", .integer).notNull()
                t.column("losses", .integer).notNull()
                t.column("winRate", .double).notNull()
                t.column("averageRMultiples", .double).notNull()
                t.column("expectancy", .double).notNull()
                t.column("avgRRR", .double).notNull()
                t.column("sharpe", .double).notNull()
                t.column("sortino", .double).notNull()
                t.column("maxDrawdown", .double).notNull()
                t.column("calmarRatio", .double).notNull()
                t.column("profitFactor", .double).notNull()
                t.column("ulcerIndex", .double).notNull()
                t.column("recoveryFactor", .double).notNull()
                t.column("equityVariance", .double).notNull()
                t.column("returnSpread50", .double).notNull()
            }
            try db.create(index: "backtestEvaluation_strategyUuid_idx", on: "backtestEvaluation", columns: ["strategyUuid"])
            
            try db.create(table: "backtestEquity") { t in
                t.column("tradeNumber", .integer).notNull()
                t.column("equity", .double).notNull()
                
                t.column("evaluationId", .integer)
                    .notNull()
                    .references("backtestEvaluation", onDelete: .cascade)
            }
            try db.create(index: "backtestEquity_evaluationId_idx", on: "backtestEquity", columns: ["evaluationId"])
            
            try db.create(table: "indicatorTestExtension") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("sma5", .double).notNull()
                t.column("sma7", .double).notNull()
                t.column("atr5", .double).notNull()
                t.column("atr7", .double).notNull()
                t.column("rsi5", .double).notNull()
                t.column("rsi7", .double).notNull()
                t.column("stoch5", .double).notNull()
                t.column("stoch7", .double).notNull()
                
                t.column("klineId", .integer)
                    .notNull()
                    .references("kline", onDelete: .cascade)
            }
            try db.create(index: "indicatorTestExtension_klineId_idx", on: "indicatorTestExtension", columns: ["klineId"])

        }

        return migrator
    }
    
    
    // MARK: - Public API: actor-gated DB access
    @discardableResult
    public func read<T>(_ body: (Database) throws -> T) throws -> T {
        try dbPool.read(body)
    }

    @discardableResult
    public func write<T>(_ body: (Database) throws -> T) throws -> T {
        try dbPool.write(body)
    }

    // Optional: fully async write that frees the actor immediately (no return value)
    public func writeAsync(_ body: @Sendable @escaping (Database) throws -> Void) async throws {
        let pool = dbPool // capture inside actor
        try await withCheckedThrowingContinuation { cont in
            pool.asyncWrite(
                { db in
                    try body(db)
                },
                completion: { _, result in
                    switch result {
                    case .success:
                        cont.resume()
                    case .failure(let error):
                        cont.resume(throwing: error)
                    }
                }
            )
        }
    }
}
