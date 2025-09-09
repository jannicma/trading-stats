import Foundation

public enum TradeAction {
    case open(order: Order)
    case cancel(orderId: UUID)
    case modifyOrder(orderId: UUID, update: OrderUpdate)
    case close(positionId: UUID)
    case modifyPosition(positionId: UUID, update: PositionUpdate)
}
