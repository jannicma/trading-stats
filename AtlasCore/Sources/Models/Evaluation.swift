//
//  Evaluation.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

import Foundation

public struct EquityPoint: Codable, Sendable, Hashable, Identifiable {
    public init(step: Int, equity: Double) {
        self.step = step
        self.equity = equity
    }
    public var id = UUID()
    public let step: Int
    public let equity: Double
}


public struct Evaluation: Codable, Sendable, Hashable, Identifiable {
    public init(id: Int = 0, timeframe: Int? = nil, symbol: String? = nil, paramSet: ParameterSet? = nil, trades: Int, wins: Int, losses: Int, winRate: Double, averageRMultiples: Double, expectancy: Double, avgRRR: Double, sharpe: Double, sortino: Double, maxDrawdown: Double, calmarRatio: Double, profitFactor: Double, ulcerIndex: Double, recoveryFactor: Double, equityVariance: Double, returnSpread50: Double, equityPoints: [EquityPoint] = []) {
        self.id = id
        self.timeframe = timeframe
        self.symbol = symbol
        self.paramSet = paramSet
        self.trades = trades
        self.wins = wins
        self.losses = losses
        self.winRate = winRate
        self.averageRMultiples = averageRMultiples
        self.expectancy = expectancy
        self.avgRRR = avgRRR
        self.sharpe = sharpe
        self.sortino = sortino
        self.maxDrawdown = maxDrawdown
        self.calmarRatio = calmarRatio
        self.profitFactor = profitFactor
        self.ulcerIndex = ulcerIndex
        self.recoveryFactor = recoveryFactor
        self.equityVariance = equityVariance
        self.returnSpread50 = returnSpread50
        self.equityCurve = equityPoints
    }
    
    public var id: Int = 0
    public var timeframe: Int?
    public var symbol: String?
    public var paramSet: ParameterSet?
    
    public var trades: Int
    public var wins: Int
    public var losses: Int
    public var winRate: Double

    // R-multiple stats (remain in R)
    public var averageRMultiples: Double      // mean R across all trades

    // Money-based stats (P&L uses price movement * volume)
    public var expectancy: Double             // average money P&L per trade
    public var avgRRR: Double                 // average reward:risk from TP vs SL distances
    public var sharpe: Double                 // Sharpe computed on money P&L per trade
    public var sortino: Double                // Sortino on money P&L per trade
    public var maxDrawdown: Double            // max peak-to-trough of cumulative money equity
    public var calmarRatio: Double            // net money profit / |maxDrawdown|
    public var profitFactor: Double           // grossProfit / grossLoss (money)
    public var ulcerIndex: Double             // sqrt(mean( drawdownFraction^2 )) on money equity
    public var recoveryFactor: Double         // net money profit / |maxDrawdown|
    public var equityVariance: Double         // variance of cumulative money equity
    public var returnSpread50: Double         // max(minus) min of money P&L for last 50 trades
    
    public var equityCurve: [EquityPoint]
}
