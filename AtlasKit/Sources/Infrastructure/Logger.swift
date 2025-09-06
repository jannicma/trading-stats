//
//  Logger.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 06.09.2025.
//
import Foundation
import AtlasVault

public actor Logger {    
    public static let shared = Logger()
    private init () {
        do{
            fileWriter = try .init(forLogging: true)
        } catch {
            print("error on initializing FileWriter: \(error)")
            fatalError()
        }
    }
    
    private let fileWriter: FileWriter

    private var minimumLevel: LogLevel = .debug
    private let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    // MARK: - Logging
    func setMinimumLevel(_ level: LogLevel) {
        minimumLevel = level
    }

    func log(_ message: String, level: LogLevel = .info) async {
        guard level >= minimumLevel else { return }

        let timestamp = dateFormatter.string(from: Date())
        let line = "[\(timestamp)] [\(level.label)] \(message)"
        
        await fileWriter.write(line)
    }
}

