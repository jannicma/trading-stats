//
//  OsHelpers.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 10.09.2025.
//
import Foundation

public enum OsHelpers {
    public static func defaultConcurrencyCores() -> Int {
        // Try to read the number of performance cores (P-cores).
        var n: Int32 = 0
        var size = MemoryLayout<Int32>.size
        if sysctlbyname("hw.perflevel0.physicalcpu", &n, &size, nil, 0) == 0, n > 0 {
            return Int(n)
        }
        // Otherwise, use activeProcessorCount but leave one core free for OS/UI.
        return max(1, ProcessInfo.processInfo.activeProcessorCount - 1)
    }
}
