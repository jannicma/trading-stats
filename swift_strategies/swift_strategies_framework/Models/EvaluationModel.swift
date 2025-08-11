//
//  EvaluationModel.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

struct EvaluationModel: Codable{
    var timeframe: String?
    var symbol: String?
    var paramSet: ParameterSet?
    
    var trades: Int
    var wins: Int
    var losses: Int
    var winRate: Double

    // R-multiple stats (remain in R)
    var averageRMultiples: Double      // mean R across all trades

    // Money-based stats (P&L uses price movement * volume)
    var expectancy: Double             // average money P&L per trade
    var avgRRR: Double                 // average reward:risk from TP vs SL distances
    var sharpe: Double                 // Sharpe computed on money P&L per trade
    var sortino: Double                // Sortino on money P&L per trade
    var maxDrawdown: Double            // max peak-to-trough of cumulative money equity
    var calmarRatio: Double            // net money profit / |maxDrawdown|
    var profitFactor: Double           // grossProfit / grossLoss (money)
    var ulcerIndex: Double             // sqrt(mean( drawdownFraction^2 )) on money equity
    var recoveryFactor: Double         // net money profit / |maxDrawdown|
    var equityVariance: Double         // variance of cumulative money equity
    var returnSpread50: Double         // max(minus) min of money P&L for last 50 trades
}
