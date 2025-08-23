//
//  JsonController.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 23.08.2025.
//


import Foundation

public struct JsonController {
    public static func saveToJSON<T: Encodable>(_ objects: [T], filePath: String) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(objects)
            let fileURL = URL(fileURLWithPath: filePath)
            try jsonData.write(to: fileURL)
            print("Saved \(objects.count) item(s) to '\(fileURL.lastPathComponent)'")
        } catch {
            print("Failed to save JSON file: \(error.localizedDescription)")
        }
    }
}
