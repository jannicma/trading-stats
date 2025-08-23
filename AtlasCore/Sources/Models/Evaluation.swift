//
//  Evaluation.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public struct Evaluation: Codable{
    public var timeframe: String?
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
}
