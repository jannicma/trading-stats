//
//  Parameter.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 18.07.2025.
//

struct Parameter{
    var name: String
    var value: Double
}

struct ParameterSet{
    var parameters: [Parameter]
}

struct ParameterRequirements{
    var name: String
    var minValue: Double
    var maxValue: Double
    var step: Double
}
