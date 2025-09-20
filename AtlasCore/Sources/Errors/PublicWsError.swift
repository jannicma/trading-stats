//
//  PublicWsError.swift
//  AtlasCore
//
//  Created by Jannic Marcon on 19.09.2025.
//

public enum PublicWsError: Error, Sendable {
    case notConnected
    case invalidMessage(String)
    case websocketClosed(String)
}
