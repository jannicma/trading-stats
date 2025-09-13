import AtlasCore
import Foundation

internal struct BacktestExecutor: Executor {
    private var openOrders: [Order] = []
    private var closedPositions: [Position] = []
    private var openPositions: [Position] = []
    
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
                submitHandleClosePosition(positionId: id, marketPrice: marketPrice!, time: time!)
            case .modifyPosition(positionId: let id, update: let update):
                submitHandleModifyPosition(positionId: id, update: update)
            }
        }
    }
    
    public mutating func simulatePositionUpdates(candle: Candle) {
        var idsEntered: [UUID] = []
        for (idx, order) in openOrders.enumerated().reversed() {
            if simulateEntry(idx: idx, order: order, candle: candle){
                idsEntered.append(order.id)
            }
        }
        openOrders.removeAll(where: {idsEntered.contains($0.id)})
        
        for (idx, pos) in openPositions.enumerated().reversed() {
            simulateExits(idx: idx, position: pos, candle: candle)
        }
    }
    
    public func getOpenOrders() -> [Order] {
        return openOrders
    }
    
    public func getOpenPositions() -> [Position] {
        return openPositions
    }
    
    public func getAllClosedPositions() -> [Position] {
        return closedPositions
    }
    
    private mutating func submitHandleOpen(order: Order, marketPrice: Double, time: Int){
        switch order.type {
        case .limit(_):
            openOrders.append(order)
        case .market:
            let newPosition = Position(id: UUID(), symbol: order.symbol, side: order.side, entryPrice: marketPrice, entryTime: time, entryType: .taker, sl: order.sl, tp: order.tp, quantity: order.quantity, open: true)
            openPositions.append(newPosition)
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
    
    private mutating func submitHandleClosePosition(positionId: UUID, marketPrice: Double, time: Int) {
        if let idx = openPositions.firstIndex(where: {$0.id == positionId}) {
            var position = openPositions.remove(at: idx)
            position.exitPrice = marketPrice
            position.exitTime = time
            position.exitType = .taker
            position.exitReason = .manual
            position.open = false
            closedPositions.append(position)
        } else {
            assert(false, "Position not found")
        }
    }
    
    private mutating func submitHandleModifyPosition(positionId: UUID, update: PositionUpdate){
        if let idx = openPositions.firstIndex(where: {$0.id == positionId}) {
            if let newSL = update.newSL{
                openPositions[idx].sl = newSL
            }
            if let newTP = update.newTP{
                openPositions[idx].tp = newTP
            }
        } else {
            assert(false , "Position not found")
        }
    }
    
    private mutating func simulateEntry(idx: Int, order: Order, candle: Candle) -> Bool {
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
                openPositions.append(position)
                return true
            }
        }
        return false
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
            var closedPosition = openPositions.remove(at: idx)
            closedPosition.exitPrice = exitPrice
            closedPosition.exitTime = candle.time
            closedPosition.exitType = .taker
            closedPosition.exitReason = exitReason
            closedPosition.open = false
            closedPositions.append(closedPosition)
        }
    }
}
