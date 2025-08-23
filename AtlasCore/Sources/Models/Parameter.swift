//
//  Parameter.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public struct Parameter: Codable{
    var name: String
    var value: Double
}

public struct ParameterSet: Codable{
    var parameters: [Parameter]
    
    var stringRepresentation: String {
        get {
            var paramText: [String] = []
            for parameter in parameters {
                paramText.append("\(parameter.name): \(parameter.value)")
            }
            return paramText.joined(separator: "\n")
        }
    }
}

struct ParameterRequirements{
    var name: String
    var minValue: Double
    var maxValue: Double
    var step: Double
}
