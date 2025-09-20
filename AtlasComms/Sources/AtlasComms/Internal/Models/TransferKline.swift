//
//  TransferKline.swift
//  AtlasComms
//
//  Created by Jannic Marcon on 19.09.2025.
//

import Foundation

public struct TransferKline: Sendable {
    let symbol: String
    let resolution: Int
    let time: Int
    let open: Decimal
    let high: Decimal
    let low: Decimal
    let close: Decimal
    let volume: Decimal
    let isFinal: Bool
}
