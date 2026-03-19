//
//  RotatingFileLogHandler.swift
//  SwiftLogger
//
//  Created by Sion on 2026/3/19.
//

import Foundation
import SwiftLogger

/// A protocol that extends `FileHandler` to add interfaces for log rotation.
///
/// Log rotation is the process of archiving the current log file and starting a new one
/// based on certain criteria, such as file size or time. This helps manage disk space.
public protocol RotatingFileLogHandler: FileHandler {
    
    associatedtype RotatingOptions: Hashable

    var path: String { get set }
    
    var logDir: String? { get }
    var logFileName: String { get }
    var logIndex: UInt { get set }
    
    var options: RotatingOptions { get }

    var max: UInt? { get }
    
    func rotate(data: Data) -> String?

    init(label: String, path: String, encoding: String.Encoding, options: RotatingOptions, max: UInt?)
}

extension RotatingFileLogHandler {
    public var logDir: String? {
        return (path as NSString).deletingLastPathComponent
    }
    
    public var logFileName: String {
        return (path as NSString).lastPathComponent
    }
}

extension RotatingFileLogHandler {
    public func log(level: Logger.Level,
                     message: Logger.Message,
                     metadata: Logger.Metadata?,
                     source: String,
                     file: String,
                     function: String,
                     line: UInt) {
        let data = buildMessage(level: level, message: message, metadata: metadata, file: file, function: function, line: line)
        
        if let newLogPath = rotate(data: data) {
            self.stream?.rotate(to: newLogPath)
        }
        
        stream?.write(data)
    }
}
