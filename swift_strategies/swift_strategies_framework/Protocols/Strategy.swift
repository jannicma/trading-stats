//
//  Strategy.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

protocol Strategy {
    func backtest(chart: Chart, paramSet: ParameterSet) -> EvaluationModel
    func getRequiredParameters() -> [ParameterRequirements]
}
