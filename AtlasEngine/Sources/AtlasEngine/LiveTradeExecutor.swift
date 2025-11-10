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
        if actions.count == 0 { return }
        
        let now = Date()
        let iso = ISO8601DateFormatter()
        let nowString = iso.string(from: now)
        
        let actionsDescription: String = actions.map { action in
            switch action {
            case .open(let order):
                return "open(order: id=\(order.id), symbol=\(order.symbol), side=\(order.side), type=\(order.type), qty=\(order.quantity), sl=\(String(describing: order.sl)), tp=\(String(describing: order.tp)), feeType=\(order.entryType))"
            case .cancel(let orderId):
                return "cancel(orderId: \(orderId))"
            case .modifyOrder(let orderId, let update):
                return "modifyOrder(orderId: \(orderId), update: newPrice=\(String(describing: update.newPrice)), newQty=\(String(describing: update.newQuantity)), newSL=\(String(describing: update.newSL)), newTP=\(String(describing: update.newTP)))"
            case .close(let positionId):
                return "close(positionId: \(positionId))"
            case .modifyPosition(let positionId, let update):
                return "modifyPosition(positionId: \(positionId), update: newSL=\(String(describing: update.newSL)), newTP=\(String(describing: update.newTP)))"
            }
        }.joined(separator: ", ")
        
        print("[LiveTradeExecutor.submit] time=\(nowString) epoch=\(now.timeIntervalSince1970) actions=[\(actionsDescription)] marketPrice=\(String(describing: marketPrice)) timeParam=\(String(describing: time))")
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
