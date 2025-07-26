//
//  ArrayExtention.swift
//  swift_strategies
//
//  Created by Jannic Marcon on 14.07.2025.
//

extension Array {
    func chunked(into size: Int) -> [ArraySlice<Element>] {
        stride(from: 0, to: count, by: size).map {
            self[$0..<Swift.min($0 + size, count)]
        }
    }
}
