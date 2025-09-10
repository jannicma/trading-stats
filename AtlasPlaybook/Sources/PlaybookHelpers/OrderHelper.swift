//
//  OrderHelper.swift
//  AtlasPlaybook
//
//  Created by Jannic Marcon on 10.09.2025.
//

public enum OrderHelper {
    public static func computeVolume(slDistance: Double, startBalance: Double, riskPerTradePercentage: Double) -> Double {
        let risk = startBalance * riskPerTradePercentage
        let positionSize = risk / slDistance
        return positionSize
    }
}
