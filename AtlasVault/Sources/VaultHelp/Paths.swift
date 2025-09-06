//
//  DBPaths.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 24.08.2025.
//
import Foundation

enum Paths {
    static func databaseURL(appName: String = "AtlasVault") throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folder = base.appendingPathComponent(appName, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("app.sqlite")
    }
    
    static func logUrl(appName: String = "AtlasVault") throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folder = base.appendingPathComponent(appName, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("app.log")

    }
}
