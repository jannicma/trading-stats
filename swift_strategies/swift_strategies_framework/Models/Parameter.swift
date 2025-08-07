//
//  Parameter.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

public struct Parameter{
    var name: String
    var value: Double
}

public struct ParameterSet{
    var parameters: [Parameter]
}

struct ParameterRequirements{
    var name: String
    var minValue: Double
    var maxValue: Double
    var step: Double
}
