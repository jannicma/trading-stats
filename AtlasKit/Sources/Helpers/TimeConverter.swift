//
//  TimeConverter.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 23.08.2025.
//

import Foundation

public struct TimeConverter {
    static func getYearAndMonth(from unixTimestamp: Int) -> (year: Int, month: Int)? {
        let interval = TimeInterval(unixTimestamp) / 1000.0
        let date = Date(timeIntervalSince1970: interval)
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let components = calendar.dateComponents([.year, .month], from: date)
        if let year = components.year, let month = components.month {
            return (year, month)
        } else {
            return nil
        }
    }
    
    public static func addSeconds(_ seconds: Int, unixMillis: Int) -> Int {
        return unixMillis + (1000 * seconds)
    }
}
