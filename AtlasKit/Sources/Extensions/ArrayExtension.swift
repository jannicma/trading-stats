//
//  ArrayExtension.swift
//  AtlasKit
//
//  Created by Jannic Marcon on 23.08.2025.
//

public extension Array {
    public func chunked(into size: Int) -> [ArraySlice<Element>] {
        stride(from: 0, to: count, by: size).map {
            self[$0..<Swift.min($0 + size, count)]
        }
    }
}
