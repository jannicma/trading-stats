//
//  Indicator.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 06.08.2025.
//

public enum Indicator {
    case sma(period: Int)
    case atr(length: Int)
    
    var name: String{
        switch self {
        case .sma(period: let p):
            return "SMA\(p)"
        case .atr(length: let l):
            return "ATR\(l)"
        }
    }
}
