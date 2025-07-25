//
//  Strategy.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 12.07.2025.
//

protocol Strategy {
    func backtest(chart: [IndicatorCandle], paramSet: ParameterSet) -> EvaluationModel
    func getRequiredParameters() -> [ParameterRequirements]
}
