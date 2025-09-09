import AtlasCore
import Foundation

struct BacktestExecutor: Executor {
    private var openOrders: [Order]
    private var allPositions: [Position]
    
    public mutating func submit(_ actions: [TradeAction], marketPrice: Double?, time: Int?){
        for action in actions {
            switch action {
            case .open(order: let order):
                submitHandleOpen(order: order, marketPrice: marketPrice!, time: time!)
            case .cancel(orderId: let id):
                submitHandleCancel(orderId: id)
            case .modifyOrder(orderId: let id, update: let update):
                submitHandleModifyOrder(orderId: id, update: update)
            case .close(positionId: let id):
                submitHandleClosePosition(orderId: id, marketPrice: marketPrice!, time: time!)
            case .modifyPosition(positionId: let id, update: let update):
                submitHandleModifyPosition(positionId: id, update: update)
            }
        }
    }
    
    public mutating func simulatePositionUpdates(candle: Candle) {
        for (idx, order) in openOrders.enumerated() {
            simulateEntry(idx: idx, order: order, candle: candle)
        }
        
        for (idx, pos) in allPositions.filter({$0.open}).enumerated() {
            simulateExits(idx: idx, position: pos, candle: candle)
        }
    }
    
    public func getOpenOrders() -> [Order] {
        return openOrders
    }
    
    public func getOpenPositions() -> [Position] {
        return allPositions.filter{$0.open}
    }
    
    public func getAllClosedPositions() -> [Position] {
        return allPositions.filter{$0.open == false}
    }
    
    private mutating func submitHandleOpen(order: Order, marketPrice: Double, time: Int){
        switch order.type {
        case .limit(let price):
            openOrders.append(order)
        case .market:
            let newPosition = Position(id: UUID(), symbol: order.symbol, side: order.side, entryPrice: marketPrice, entryTime: time, entryType: .taker, sl: order.sl, tp: order.tp, quantity: order.quantity, open: true)
            allPositions.append(newPosition)
        }
    }
    
    private mutating func submitHandleCancel(orderId: UUID){
        openOrders.removeAll(where: {$0.id == orderId})
    }
    
    private mutating func submitHandleModifyOrder(orderId: UUID, update: OrderUpdate){
        if let idx = openOrders.firstIndex(where: { $0.id == orderId }) {
            if let newPrice = update.newPrice{
                let newLimitPrice: OrderType = .limit(price: newPrice)
                openOrders[idx].type = newLimitPrice
            }
            openOrders[idx].quantity = update.newQuantity ?? openOrders[idx].quantity
            openOrders[idx].sl = update.newSL ?? openOrders[idx].sl
            openOrders[idx].tp = update.newTP ?? openOrders[idx].tp
        } else {
            assert(false, "Order not found")
        }
    }
    
    private mutating func submitHandleClosePosition(orderId: UUID, marketPrice: Double, time: Int){
        if let idx = allPositions.firstIndex(where: {$0.id == orderId}) {
            allPositions[idx].exitPrice = marketPrice
            allPositions[idx].exitTime = time
            allPositions[idx].exitType = .taker
            allPositions[idx].exitReason = .manual
            allPositions[idx].open = false
        } else {
            assert(false, "Position not found")
        }
    }
    
    private mutating func submitHandleModifyPosition(positionId: UUID, update: PositionUpdate){
        if let idx = allPositions.firstIndex(where: {$0.id == positionId}) {
            allPositions[idx].sl = update.newSL ?? allPositions[idx].sl
            allPositions[idx].tp = update.newTP ?? allPositions[idx].tp
        } else {
            assert(false , "Position not found")
        }
    }
    
    private mutating func simulateEntry(idx: Int, order: Order, candle: Candle){
        switch order.type {
        case .market:
            assert(false, "Market order in orders")
        case .limit(let price):
            var isFilled: Bool = false
            
            switch order.side {
            case .long:
                isFilled = candle.low <= price
            case .short:
                isFilled = candle.high >= price
            }
            
            if isFilled {
                let position = Position(id: UUID(), symbol: order.symbol, side: order.side, entryPrice: price, entryTime: candle.time, entryType: order.entryType, sl: order.sl, tp: order.tp, quantity: order.quantity, open: true)
                allPositions.append(position)
                openOrders.remove(at: idx)
            }
        }
    }
    
    private mutating func simulateExits(idx: Int, position: Position, candle: Candle) {
        var exitPrice: Double?
        var exitReason: ExitReason?
        switch position.side {
        case .long:
            if let sl = position.sl, candle.low <= sl {
                exitPrice = sl;
                exitReason = .stopLoss
            }
            if let tp = position.tp, candle.high >= tp {
                exitPrice = tp;
                exitReason = .takeProfit
            }
        case .short:
            if let sl = position.sl, candle.high >= sl {
                exitPrice = sl;
                exitReason = .stopLoss
            }
            if let tp = position.tp, candle.low <= tp {
                exitPrice = tp;
                exitReason = .takeProfit
            }
        }
        
        if let exitPrice {
            allPositions[idx].exitPrice = exitPrice
            allPositions[idx].exitTime = candle.time
            allPositions[idx].exitType = .taker
            allPositions[idx].exitReason = exitReason
            allPositions[idx].open = false
        }
    }
}
