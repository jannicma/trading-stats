//
//  FileWriter.swift
//  AtlasVault
//
//  Created by Jannic Marcon on 06.09.2025.
//
import Foundation

public actor FileWriter {
    private let handle: FileHandle
    
    public init(forLogging: Bool, initPath: String? = nil) throws {
        let path = forLogging ? try Paths.logUrl().absoluteString : initPath!
        
        FileManager.default.createFile(atPath: path, contents: nil)
        handle = try FileHandle(forWritingTo: URL(fileURLWithPath: path))
        try handle.seekToEnd()
    }
    
    public func write(_ message: String) async {
        if let data = (message + "\n").data(using: .utf8) {
            try? handle.write(contentsOf: data)
        }
    }
}
