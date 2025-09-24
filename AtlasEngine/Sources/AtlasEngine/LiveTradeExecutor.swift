//
//  LiveTradeExecutor.swift
//  AtlasEngine
//
//  Created by Jannic Marcon on 24.09.2025.
//
import Foundation
import AtlasCore

internal struct LiveTradeExecutor: Executor {
    private let client: any ExchangeClient
    public init(client: any ExchangeClient) {
        self.client = client
    }
    
    public func submit(_ actions: [TradeAction], marketPrice: Double? = nil, time: Int? = nil) async {
        // logic
    }
    
    public mutating func simulatePositionUpdates(candle: Candle) {
        
    }
    
    public func getOpenOrders() -> [Order] {
        return []
    }
    
    public func getOpenPositions() -> [Position] {
        return []
    }
    
    public func getAllClosedPositions() -> [Position] {
        return []
    }
}
