//
// LogHandler.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2025/12/31
//

import Foundation

@preconcurrency public protocol _SwiftLogSendableLogHandler: Sendable { }

public protocol LogHandler: _SwiftLogSendableLogHandler {

    var metadataProvider: Logger.MetadataProvider? { get set }
    
    func log(level: Logger.Level,
             message: Logger.Message,
             metadata: Logger.Metadata?,
             source: String,
             file: String,
             function: String,
             line: UInt)

    subscript(metadataKey _: String) -> Logger.Metadata.Value? { get set }
    
    var metadata: Logger.Metadata { get set }
    
    var logLevel: Logger.Level { get set }
}

extension LogHandler {
    public var metadataProvider: Logger.MetadataProvider? {
        get {
            nil
        }
        set {
            
        }
    }
}
