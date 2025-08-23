//
//  Parameter.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 23.08.2025.
//

public struct Parameter: Codable, Sendable{
    public init(name: String, value: Double) {
        self.name = name
        self.value = value
    }
    
    public var name: String
    public var value: Double
}

public struct ParameterSet: Codable, Sendable{
    public init(parameters: [Parameter]) {
        self.parameters = parameters
    }
    
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
    public var name: String
    public var minValue: Double
    public var maxValue: Double
    public var step: Double
    
    public init(name: String, minValue: Double, maxValue: Double, step: Double) {
        self.name = name
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
    }
}
