//
//  JsonController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 13.07.2025.
//
import Foundation

struct JsonController{
    static func saveEvaluationsToJson(objects: [EvaluationModel], filename: String) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Make the JSON human-readable

        do {
            // Encode the array of objects to JSON Data
            let jsonData = try encoder.encode(objects)

            // Determine the full file path
            let fileURL = URL(fileURLWithPath: filename)

            // Write the JSON data to the file
            try jsonData.write(to: fileURL)
            print("Successfully saved \(objects.count) objects to \(fileURL.lastPathComponent)")

        } catch {
            print("Error saving objects to JSON file: \(error.localizedDescription)")
        }
    }

}
