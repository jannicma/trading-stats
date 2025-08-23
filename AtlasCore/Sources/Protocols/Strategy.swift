//
//  Strategy.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public protocol Strategy {
    func backtest(chart: Chart, paramSet: ParameterSet) -> [Trade]
    func getRequiredParameters() -> [ParameterRequirements]
    func getRequiredIndicators() -> [Indicator]
}
