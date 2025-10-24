//
//  StrategyTypes.swift
//  AtlasPlaybook
//
//  Created by Jannic Marcon on 25.09.2025.
//
import AtlasCore
import Foundation

public enum StrategyType: CaseIterable, Identifiable {
    case candleBreakoutStrategy
    case stochRsiStrategy
    case trippleSmaStrategy
    
    public var id: String { self.type.name }
    
    public var type: any Strategy.Type {
        switch self{
        case .candleBreakoutStrategy: return CandleBreakoutStrategy.self
        case .stochRsiStrategy: return StochRsiStrategy.self
        case .trippleSmaStrategy: return TrippleSmaStrategy.self
        }
    }
    
    public var name: String {
        type.name
    }
    
    public func make(id: UUID) -> any Strategy {
        type.init(id: id)
    }
}
