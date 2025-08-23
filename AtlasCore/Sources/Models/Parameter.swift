//
//  Parameter.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public struct Parameter: Codable{
    public var name: String
    public var value: Double
}

public struct ParameterSet: Codable{
    public var parameters: [Parameter]
    
    public var stringRepresentation: String {
        get {
            var paramText: [String] = []
            for parameter in parameters {
                paramText.append("\(parameter.name): \(parameter.value)")
            }
            return paramText.joined(separator: "\n")
        }
    }
}

public struct ParameterRequirements{
    var name: String
    var minValue: Double
    var maxValue: Double
    var step: Double
    
    public init(name: String, minValue: Double, maxValue: Double, step: Double) {
        self.name = name
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
    }
}
