//
// LogHandler.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2025/12/31
//

@preconcurrency public protocol _SwiftLogSendableLogHandler: Sendable { }

public protocol LogHandler: _SwiftLogSendableLogHandler {

    var metadataProvider: Logger.MetadataProvider? { get set }

    var metadata: Logger.Metadata { get set }
    
    var logLevel: Logger.Level { get set }

    subscript(metadata: String) -> Logger.Metadata.Value? { get set }
    
    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt)

}