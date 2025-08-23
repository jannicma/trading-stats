//
//  Indicator.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public enum Indicator: Sendable {
    case sma(period: Int)
    case atr(length: Int)
    case rsi(length: Int)
    case stoch(KLen: Int)
    
    public var name: String{
        switch self {
        case .sma(period: let p):
            return "SMA\(p)"
        case .atr(length: let l):
            return "ATR\(l)"
        case .rsi(length: let l):
            return "RSI\(l)"
        case .stoch(KLen: let kLen):
            return "STOCH\(kLen)"
        }
    }
}
