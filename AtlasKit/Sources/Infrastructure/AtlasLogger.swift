//
//  Logger.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 06.09.2025.
//
import Foundation
import AtlasVault
import AtlasCore

public actor AtlasLogger {    
    public static let shared = AtlasLogger()
    private init () {
        do{
            fileWriter = try .init(forLogging: true)
        } catch {
            print("error on initializing FileWriter: \(error)")
            fatalError()
        }
    }
    
    private let fileWriter: FileWriter

    private var minimumLevel: AtlasLogLevel = .debug
    private let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    // MARK: - Logging
    func setMinimumLevel(_ level: AtlasLogLevel) {
        minimumLevel = level
    }

    public func log(_ message: String, level: AtlasLogLevel = .info) async {
        guard level >= minimumLevel else { return }

        let timestamp = dateFormatter.string(from: Date())
        let line = "[\(timestamp)] [\(level.label)] \(message)"
        
        await fileWriter.write(line)
    }
}

