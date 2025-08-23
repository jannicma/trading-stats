//
//  ParameterGenerator.swift
//  AtlasSim
//
//  Created by Jannic Marcon on 23.08.2025.
//
import AtlasCore

struct ParameterGenerator{
    func generateParameters(requirements: [ParameterRequirements], parameters: [ParameterSet] = []) -> [ParameterSet]{
        //early return when we reached no more requirements
        guard let firstRequirement = requirements.first else{
            return parameters
        }
        
        //generating a parameter for every possible value in ONE parameter requirement
        var newParams: [Parameter] = []
        for i in stride(from: firstRequirement.minValue, through: firstRequirement.maxValue, by: firstRequirement.step){
            newParams.append(Parameter(name: firstRequirement.name, value: i))
        }
        
        //merging all previously generated parameters to the newly generated ones
        var newParameterSets: [ParameterSet] = []
        for newParam in newParams {
            if parameters.isEmpty{
                var newSet = ParameterSet(parameters: [])
                newSet.parameters.append(newParam)
                newParameterSets.append(newSet)
            }
            else{
                for parameter in parameters {
                    var newSet = ParameterSet(parameters: parameter.parameters)
                    newSet.parameters.append(newParam)
                    newParameterSets.append(newSet)
                }
            }
        }
        
        //dropping first requiremet (current one) and running the funciton again with the next param
        let continueRequirements = Array(requirements.dropFirst(1))
        newParameterSets = generateParameters(requirements: continueRequirements, parameters: newParameterSets)
        
        return newParameterSets
    }
}
