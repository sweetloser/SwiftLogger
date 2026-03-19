//
//  FileHandler.swift
//  SwiftLogger
//
//  Created by Sion on 2026/3/18.
//

import Foundation
import SwiftLogger


private let _formatter = SendableDataFormatter()

public protocol FileHandler: LogHandler {
    
    var encoding: String.Encoding { get set }

    var label: String { get }

    var prettyMetadata: String? { get }

    var stream: FileStream? { get }
    
}

public extension FileHandler {

    func prettify(_ metadata: Logger.Metadata) -> String? {
        if metadata.isEmpty {
            return nil
        } else {
            return metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: " ")
        }
    }

    // build message with level, message, metadata, file, function, line.
    // return message as Data.
    // if encoding failed, use utf8. if also failed, return empty data.
    internal func buildMessage(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) -> Data {
        
        let dateString = _formatter.string(from: Date())
        
        let metadataString = (metadata?.isEmpty ?? true) ? self.prettyMetadata : prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, provided in provided }))

        var formatMessage = "\(dateString) [\(level)] \(label):\(metadataString.map { " \($0)"} ?? "") \(message)"

        if self.logLevel <= .debug {
            formatMessage += " (\(file):\(line) \(function))"
        }
        formatMessage += "\n"

        guard let data = formatMessage.data(using: self.encoding) else {
            // encoding failed, use utf8.
            guard let utf8Data = formatMessage.data(using: .utf8) else {
                // if also failed with utf8, return empty data. and print error message.
                print("❌❌❌encoding failed with \(self.encoding) and utf8, return empty data.❌❌❌")
                return Data()
            }
            return utf8Data
        }
        return data
    }

    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }
}

///  SendableDataFormatter is a thread-safe formatter for ISO8601DateFormatter.
private struct SendableDataFormatter: @unchecked Sendable {
    private let _formatter: ISO8601DateFormatter
    private let _lock = NSLock()
    init() {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        _formatter = fmt
    }
    
    func string(from data: Date) -> String {
        _lock.lock()
        defer { _lock.unlock() }
        return _formatter.string(from: data)
    }
}

