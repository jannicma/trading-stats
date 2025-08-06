//
//  JsonController.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 27.07.2025.
//

import Foundation

struct JsonController {
    static func saveToJSON<T: Encodable>(_ objects: [T], filePath: String) {
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
