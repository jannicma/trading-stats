//
//  LogLevel.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 06.09.2025.
//


public enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case error = 2
    
    var label: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .error: return "ERROR"
        }
    }
    
    // Comparable conformance (so you can do level >= minLevel)
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
