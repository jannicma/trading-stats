//
//  Evaluator.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 23.08.2025.
//

import Foundation
import AtlasCore

public struct Evaluator {
    
    // MARK: - Performance helpers (daily, percentage-based)
    private struct DailyPoint { let date: Date; let equity: Double }

    private static func dailyRiskFreeRate(annualRf: Double, periodsPerYear: Double) -> Double {
        return pow(1.0 + annualRf, 1.0 / periodsPerYear) - 1.0
    }

    private static func buildDailyEquity(trades: [Trade], startEquity: Double, calendar: Calendar) -> [DailyPoint] {
        guard !trades.isEmpty else { return [] }
        var pnlByDay: [Date: Double] = [:]
        for t in trades {
            guard let exit = t.exitPrice else { continue }
            let pnl = (t.isLong ? (exit - t.entryPrice) : (t.entryPrice - exit)) * t.volume
            // Convert Int unix timestamp (seconds or milliseconds) to Date
            let rawTs = t.timestamp
            let seconds = rawTs > 1_000_000_000_000 ? Double(rawTs) / 1000.0 : Double(rawTs)
            let tsDate = Date(timeIntervalSince1970: seconds)
            let day = calendar.startOfDay(for: tsDate)
            pnlByDay[day, default: 0.0] += pnl
        }
        guard let firstDay = pnlByDay.keys.min(), let lastDay = pnlByDay.keys.max() else { return [] }
        var out: [DailyPoint] = []
        let baselineDay = calendar.date(byAdding: .day, value: -1, to: firstDay)!
        out.append(DailyPoint(date: baselineDay, equity: startEquity))

        var equity = startEquity
        var day = firstDay
        while day <= lastDay {
            equity += pnlByDay[day, default: 0.0]
            out.append(DailyPoint(date: day, equity: equity))
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        return out
    }

    private static func dailyReturns(from equitySeries: [DailyPoint]) -> [Double] {
        guard equitySeries.count >= 2 else { return [] }
        var r: [Double] = []
        r.reserveCapacity(equitySeries.count - 1)
        for i in 1..<equitySeries.count {
            let e0 = equitySeries[i-1].equity
            let e1 = equitySeries[i].equity
            guard e0 > 0 else { continue }
            r.append((e1 / e0) - 1.0)
        }
        return r
    }

    private static func sharpeFromDailyReturns(_ r: [Double], annualRf: Double, periodsPerYear: Double) -> Double {
        guard r.count > 1 else { return 0.0 }
        let rfDaily = Self.dailyRiskFreeRate(annualRf: annualRf, periodsPerYear: periodsPerYear)
        let excess = r.map { $0 - rfDaily }
        let mean = excess.reduce(0.0, +) / Double(excess.count)
        let varSample = excess.reduce(0.0) { $0 + pow($1 - mean, 2) } / Double(excess.count - 1)
        let sd = sqrt(max(0.0, varSample))
        return sd > 0 ? mean / sd * sqrt(periodsPerYear) : 0.0
    }

    private static func sortinoFromDailyReturns(_ r: [Double], marDaily: Double, periodsPerYear: Double) -> Double {
        guard r.count > 1 else { return 0.0 }
        let excess = r.map { $0 - marDaily }
        let meanExcess = excess.reduce(0.0, +) / Double(excess.count)
        let downside = excess.map { min($0, 0.0) }
        let ddVar = downside.reduce(0.0) { $0 + $1 * $1 } / Double(excess.count)
        let dd = sqrt(ddVar)
        return dd > 0 ? meanExcess / dd * sqrt(periodsPerYear) : 0.0
    }

    private static func maxDrawdownPct(equitySeries: [DailyPoint]) -> Double {
        guard !equitySeries.isEmpty else { return 0.0 }
        var peak = equitySeries.first!.equity
        var mdd: Double = 0.0
        for p in equitySeries {
            if p.equity > peak { peak = p.equity }
            if peak > 0 {
                let dd = (peak - p.equity) / peak
                if dd > mdd { mdd = dd }
            }
        }
        return mdd
    }

    private static func maxDrawdownMoney(equitySeries: [DailyPoint]) -> Double {
        guard !equitySeries.isEmpty else { return 0.0 }
        var peak = equitySeries.first!.equity
        var mdd: Double = 0.0
        for p in equitySeries {
            if p.equity > peak { peak = p.equity }
            let dd = peak - p.equity
            if dd > mdd { mdd = dd }
        }
        return mdd
    }

    private static func ulcerIndexPct(equitySeries: [DailyPoint]) -> Double {
        guard !equitySeries.isEmpty else { return 0.0 }
        var peak = equitySeries.first!.equity
        var squares: [Double] = []
        for p in equitySeries {
            if p.equity > peak { peak = p.equity }
            guard peak > 0 else { continue }
            let dd = (peak - p.equity) / peak
            squares.append(dd * dd)
        }
        guard !squares.isEmpty else { return 0.0 }
        return sqrt(squares.reduce(0.0, +) / Double(squares.count))
    }

    private static func cagr(equitySeries: [DailyPoint], calendar: Calendar) -> Double {
        guard let first = equitySeries.first, let last = equitySeries.last, first.equity > 0 else { return 0.0 }
        // If terminal equity is zero or negative, define CAGR as -100%
        if last.equity <= 0 { return -1.0 }
        let days = max(1, calendar.dateComponents([.day], from: first.date, to: last.date).day ?? 0)
        let years = Double(days) / 365.0
        guard years > 0 else { return 0.0 }
        return pow(last.equity / first.equity, 1.0 / years) - 1.0
    }
    
    public static func evaluateEvaluations(evaluations: [Evaluation]){
        for i in 0...7{
            print("Rank \(i+1): \(evaluations[i].symbol ?? "unknown")")
            Self.printEvaluation(evaluations[i])
            print("\n")
        }
    }
    
    
    public static func evaluateTrades(simulatedTrades: [Trade], printEval: Bool = false) -> Evaluation {
        // --- Inputs / constants ---
        let startEquity: Double = 100_000.0
        let periodsPerYear: Double = 365.0
        let annualRiskFree: Double = 0.0
        let calendar = Calendar.current
        
        let simTrades = simulatedTrades.sorted { $0.timestamp < $1.timestamp }

        // --- Per-trade diagnostics kept as before ---
        var rMultiples: [Double] = []
        rMultiples.reserveCapacity(simTrades.count)

        var moneyReturns: [Double] = []
        moneyReturns.reserveCapacity(simTrades.count)

        var rrRatios: [Double] = []

        let tradesCount = simTrades.count
        let wins = simTrades.filter { $0.isLong ? $0.exitPrice! > $0.entryPrice : $0.exitPrice! < $0.entryPrice}.count
        let losses = simTrades.filter { $0.isLong ? $0.exitPrice! <= $0.entryPrice : $0.exitPrice! >= $0.entryPrice}.count
        let winRate = (Double(wins) / max(Double(tradesCount), 1)) * 100

        assert(tradesCount == wins+losses, "trade wins and losses dont sum up correctly")

        var grossProfitMoney: Double = 0
        var grossLossMoney: Double = 0

        var equityPoints: [EquityPoint] = []

        for (tradeNumber, trade) in simTrades.enumerated(){
            let slDiff = abs(trade.entryPrice - trade.slPrice)
            guard slDiff > 0, let exit = trade.exitPrice else { continue }

            // R-Multiple for this trade
            let r = trade.isLong ? (exit - trade.entryPrice) / slDiff : (trade.entryPrice - exit) / slDiff
            rMultiples.append(r)

            let pnl = (trade.isLong ? (exit - trade.entryPrice) : (trade.entryPrice - exit)) * trade.volume
            moneyReturns.append(pnl)
            
            let lastEquity = equityPoints.last?.equity ?? 0.0
            let newEquityPoint = EquityPoint(step: tradeNumber, equity: lastEquity + pnl)
            equityPoints.append(newEquityPoint)

            if pnl > 0 { grossProfitMoney += pnl } else { grossLossMoney += abs(pnl) }

            let rr = 1.0 //abs(trade.tpPrice - trade.entryPrice) / slDiff
            rrRatios.append(rr)
        }

        // --- Build daily equity curve (includes non-trade days) ---
        let equityDaily: [DailyPoint] = Self.buildDailyEquity(trades: simTrades, startEquity: startEquity, calendar: calendar)
        let returnsDaily: [Double] = Self.dailyReturns(from: equityDaily)

        // --- Expectancy (money/trade) unchanged ---
        let nR = rMultiples.count
        let meanR = nR > 0 ? rMultiples.reduce(0, +) / Double(nR) : 0.0

        let nM = moneyReturns.count
        let expectancyMoney = nM > 0 ? moneyReturns.reduce(0, +) / Double(nM) : 0.0

        // --- Risk-adjusted metrics on DAILY RETURNS ---
        let sharpe = Self.sharpeFromDailyReturns(returnsDaily, annualRf: annualRiskFree, periodsPerYear: periodsPerYear)
        let sortino = Self.sortinoFromDailyReturns(returnsDaily, marDaily: 0.0, periodsPerYear: periodsPerYear)

        // Profit factor unchanged (money-based)
        let profitFactor = grossLossMoney > 0 ? grossProfitMoney / grossLossMoney : 0.0

        // Ulcer Index on PERCENT drawdowns with sqrt of mean squares
        let ulcerIndex = Self.ulcerIndexPct(equitySeries: equityDaily)

        // Equity variance (money-level variance of daily equity series)
        var equityVariance: Double = 0.0
        if equityDaily.count > 1 {
            let meanEq = equityDaily.map { $0.equity }.reduce(0.0, +) / Double(equityDaily.count)
            let varEq = equityDaily.reduce(0.0) { $0 + pow($1.equity - meanEq, 2) } / Double(equityDaily.count - 1)
            equityVariance = varEq
        }

        // Last-50 trade spread in money (unchanged)
        let window = moneyReturns.suffix(50)
        let returnSpread50 = window.isEmpty ? 0.0 : (window.max() ?? 0.0) - (window.min() ?? 0.0)

        let averageRRR = rrRatios.isEmpty ? 0.0 : rrRatios.reduce(0, +) / Double(rrRatios.count)

        // --- Calmar / MDD / Recovery ---
        let netMoney = moneyReturns.reduce(0, +)
        let mddPct = Self.maxDrawdownPct(equitySeries: equityDaily)
        let mddMoney = Self.maxDrawdownMoney(equitySeries: equityDaily)
        let cagrVal = Self.cagr(equitySeries: equityDaily, calendar: calendar)
        let calmarRatio = mddPct > 0 ? cagrVal / mddPct : 0.0
        let recoveryFactor = mddMoney > 0 ? netMoney / mddMoney : 0.0
        
        let evaluation = Evaluation(
            trades: tradesCount,
            wins: wins,
            losses: losses,
            winRate: Double(round(1000 * winRate) / 1000),
            averageRMultiples: Double(round(1000 * meanR) / 1000),
            expectancy: Double(round(1000 * expectancyMoney) / 1000),
            avgRRR: Double(round(1000 * averageRRR) / 1000),
            sharpe: Double(round(1000 * sharpe) / 1000),
            sortino: Double(round(1000 * sortino) / 1000),
            maxDrawdown: Double(round(1000 * mddMoney) / 1000),
            calmarRatio: Double(round(1000 * calmarRatio) / 1000),
            profitFactor: Double(round(1000 * profitFactor) / 1000),
            ulcerIndex: Double(round(1000 * ulcerIndex) / 1000),
            recoveryFactor: Double(round(1000 * recoveryFactor) / 1000),
            equityVariance: Double(round(1000 * equityVariance) / 1000),
            returnSpread50: Double(round(1000 * returnSpread50) / 1000),
            equityPoints: equityPoints
        )

        if printEval { Self.printEvaluation(evaluation)}
        return evaluation
    }
    
    
    private static func printEvaluation(_ evaluation: Evaluation) {
        print("Chart: \(evaluation.symbol ?? "No Symbol")")
        print("Timeframe: \(evaluation.timeframe ?? 0)")
        print(evaluation.paramSet?.stringRepresentation ?? "no Parameter Set")
        print("Total Trades: \(evaluation.trades)")
        print("Wins: \(evaluation.wins)")
        print("Losses: \(evaluation.losses)")
        print(String(format: "Win Rate: %.2f%%", evaluation.winRate))
        print(String(format: "Average R Multiples: %.4f (R)", evaluation.averageRMultiples))
        print(String(format: "Expectancy (money/trade): %.4f", evaluation.expectancy))
        print(String(format: "Average R:R (TP/SL): %.4f", evaluation.avgRRR))
        print(String(format: "Sharpe (ann., daily): %.4f", evaluation.sharpe))
        print(String(format: "Sortino (ann., daily): %.4f", evaluation.sortino))
        print(String(format: "Profit Factor (money): %.4f", evaluation.profitFactor))
        print(String(format: "Max Drawdown (money): %.4f", evaluation.maxDrawdown))
        print(String(format: "Calmar Ratio (CAGR/MDD%%): %.4f", evaluation.calmarRatio))
        print(String(format: "Recovery Factor (money): %.4f", evaluation.recoveryFactor))
        print(String(format: "Ulcer Index: %.4f", evaluation.ulcerIndex))
        print(String(format: "Equity Variance (money): %.4f", evaluation.equityVariance))
        print(String(format: "Return Spread (last 50, money): %.4f", evaluation.returnSpread50))
    }
}
