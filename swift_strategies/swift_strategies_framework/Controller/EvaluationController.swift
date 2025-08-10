//
//  EvaluationController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//
import Foundation

struct EvaluationController{
    func evaluateEvaluations(evaluations: [EvaluationModel]){
        for i in 0...7{
            print("Rank \(i+1): \(evaluations[i].symbol ?? "unknown")")
            printEvaluation(evaluations[i])
            print("\n")
        }
    }
    
    
    func evaluateTrades(simulatedTrades: [SimulatedTrade], printEval: Bool = false) -> EvaluationModel {
        var rMultiples: [Double] = []
        rMultiples.reserveCapacity(simulatedTrades.count)
        
        var moneyReturns: [Double] = []
        moneyReturns.reserveCapacity(simulatedTrades.count)
        
        var rrRatios: [Double] = []
        
        let tradesCount = simulatedTrades.count
        let wins = simulatedTrades.filter { $0.isLong ? $0.exitPrice! > $0.entryPrice : $0.exitPrice! < $0.entryPrice}.count
        let losses = simulatedTrades.filter { $0.isLong ? $0.exitPrice! < $0.entryPrice : $0.exitPrice! > $0.entryPrice}.count
        let winRate = (Double(wins) / Double(tradesCount)) * 100
        
        assert(tradesCount == wins+losses, "trade wins and losses dont sum up correctly")
        
        var grossProfitMoney: Double = 0
        var grossLossMoney: Double = 0
        
        //Money equity curve
        var equityMoney: [Double] = []
        equityMoney.reserveCapacity(tradesCount)
        var cumMoney: Double = 0.0
        var peakMoney: Double = 0.0
        var maxDDMoney: Double = 0.0
        var ulcerSquares: [Double] = []
        var downsideSquaresMoney: [Double] = []
        
        for trade in simulatedTrades{
            let slDiff = abs(trade.entryPrice - trade.slPrice)
            guard slDiff > 0, let exit = trade.exitPrice else { continue }
            
            //R-Multiple for this trade
            let r = trade.isLong ? (exit - trade.entryPrice) / slDiff : (trade.entryPrice - exit) / slDiff
            rMultiples.append(r)
            
            let pnl = (trade.isLong ? (exit - trade.entryPrice) : (trade.entryPrice - exit)) * trade.volume
            moneyReturns.append(pnl)
            
            if pnl > 0 { grossProfitMoney += pnl } else { grossLossMoney += abs(pnl) }
            if pnl < 0 { downsideSquaresMoney.append(pnl * pnl) }
            
            cumMoney += pnl // TODO: is cumMoney really needed outside of loop? why?
            equityMoney.append(cumMoney)
            
            if cumMoney > peakMoney { peakMoney = cumMoney }
            let dd = peakMoney - cumMoney
            if dd > maxDDMoney { maxDDMoney = dd }
            if peakMoney > 0 {
                let ddFrac = dd / peakMoney
                ulcerSquares.append(ddFrac * ddFrac)
            }
            
            let rr = abs(trade.tpPrice - trade.entryPrice) / slDiff
            rrRatios.append(rr)
        }
        
        let nR = rMultiples.count
        let meanR = nR > 0 ? rMultiples.reduce(0, +) / Double(nR) : 0.0
        
        let nM = moneyReturns.count
        let expectancyMoney = nM > 0 ? moneyReturns.reduce(0, +) / Double(nM) : 0.0
        
        var sharpe: Double = 0.0
        if nM > 1 {
            let variance = moneyReturns.reduce(0) { $0 + pow($1 - expectancyMoney, 2)} / Double(nM - 1)
            let std = sqrt(max(variance, 0))
            if std > 0 { sharpe = expectancyMoney / std }
        }
        
        let downsideVar = downsideSquaresMoney.isEmpty ? 0.0 : downsideSquaresMoney.reduce(0, +) / Double(downsideSquaresMoney.count)
        let downsideStd = sqrt(downsideVar)
        let sortino = downsideStd > 0 ? expectancyMoney / downsideStd : 0.0
        
        let profitFactor = grossLossMoney > 0 ? grossLossMoney / grossProfitMoney : 0.0
        let ulcerIndex = ulcerSquares.isEmpty ? 0.0 : ulcerSquares.reduce(0, +) / Double(ulcerSquares.count)
        
        var equityVariance: Double = 0.0
        if equityMoney.count > 1 {
            let meanEq = equityMoney.reduce(0, +) / Double(equityMoney.count)
            let varEq = equityMoney.reduce(0) { $0 + pow($1 - meanEq, 2)} / Double(equityMoney.count - 1)
            equityVariance = varEq
        }
        
        let window = moneyReturns.suffix(50)
        let returnSpread50 = window.isEmpty ? 0.0 : (window.max() ?? 0.0) - (window.min() ?? 0.0)
        
        let averageRRR = rrRatios.isEmpty ? 0.0 : rrRatios.reduce(0, +) / Double(rrRatios.count)
        
        let netMoney = moneyReturns.reduce(0, +)
        let maxDrowdown = maxDDMoney
        let denom = maxDrowdown > 0 ? maxDrowdown : 0.0 //why??
        let calmerRatio = denom > 0 ? netMoney / denom : 0.0        //same?
        let recoveryFactor = denom > 0 ? netMoney / denom : 0.0     //same?
        
        let evaluation = EvaluationModel(
            trades: tradesCount,
            wins: wins,
            losses: losses,
            winRate: winRate,
            riskAtrMult: 0.0,
            rewardAtrMult: 0.0,
            averageRMultiples: meanR,
            expectancy: expectancyMoney,
            avgRRR: averageRRR,
            sharpe: sharpe,
            sortino: sortino,
            maxDrawdown: maxDrowdown,
            calmarRatio: calmerRatio,
            profitFactor: profitFactor,
            ulcerIndex: ulcerIndex,
            recoveryFactor: recoveryFactor,
            equityVariance: equityVariance,
            returnSpread50: returnSpread50
        )
        
        if printEval { printEvaluation(evaluation)}
        return evaluation
    }
    
   
    /*
    func evaluateTrades(simulatedTrades: [SimulatedTrade], printEval: Bool = false) -> EvaluationModel {
        var evaluation = EvaluationModel(trades: 0, wins: 0, losses: 0, winRate: 0.0, riskAtrMult: risk, rewardAtrMult: reward, averageRMultiples: 0.0)
        
        evaluation.trades = simulatedTrades.count
        evaluation.wins = simulatedTrades.filter { $0.exitPrice == $0.tpPrice }.count
        evaluation.losses = simulatedTrades.filter { $0.exitPrice == $0.slPrice}.count
        evaluation.winRate = (Double(evaluation.wins) / Double(evaluation.trades)) * 100
        
        var allRealizedR: [Double] = []
        for trade in simulatedTrades {
            let isLong = trade.slPrice < trade.entryPrice
            let slDiff = abs(trade.entryPrice - trade.slPrice)
            let exitDiff = isLong ? trade.exitPrice! - trade.entryPrice : trade.entryPrice - trade.exitPrice!
            
            let realizedR = exitDiff / slDiff
            allRealizedR.append(realizedR)
        }
        let sumR = allRealizedR.reduce(0, +)
        evaluation.averageRMultiples = sumR / Double(allRealizedR.count)

        assert(evaluation.trades == evaluation.wins + evaluation.losses, "evaluation trades do not count up correctly")
        
        if printEval { printEvaluation(evaluation) }
        return evaluation
    }
    */
    
    private func printEvaluation(_ evaluation: EvaluationModel) {
        print("Total Trades: \(evaluation.trades)")
        print("Wins: \(evaluation.wins)")
        print("Losses: \(evaluation.losses)")
        print(String(format: "Win Rate: %.2f%%", evaluation.winRate))
        print(String(format: "ATR Risk: %.2f", evaluation.riskAtrMult))
        print(String(format: "ATR Reward: %.2f", evaluation.rewardAtrMult))
        print(String(format: "Average R Multiples: %.4f (R)", evaluation.averageRMultiples))
        print(String(format: "Expectancy (money/trade): %.4f", evaluation.expectancy))
        print(String(format: "Average R:R (TP/SL): %.4f", evaluation.avgRRR))
        print(String(format: "Sharpe (money): %.4f", evaluation.sharpe))
        print(String(format: "Sortino (money): %.4f", evaluation.sortino))
        print(String(format: "Profit Factor (money): %.4f", evaluation.profitFactor))
        print(String(format: "Max Drawdown (money): %.4f", evaluation.maxDrawdown))
        print(String(format: "Calmar Ratio (money): %.4f", evaluation.calmarRatio))
        print(String(format: "Recovery Factor (money): %.4f", evaluation.recoveryFactor))
        print(String(format: "Ulcer Index: %.4f", evaluation.ulcerIndex))
        print(String(format: "Equity Variance (money): %.4f", evaluation.equityVariance))
        print(String(format: "Return Spread (last 50, money): %.4f", evaluation.returnSpread50))
    }
}
