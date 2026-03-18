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

}

public extension FileHandler {
    internal func buildMessage(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) -> String {
        
        let dateString = _formatter.string(from: Date())

        let metadataString = metadata?.isEmpty == true ? "" : " \(metadata.map { $0.description } ?? "")"
        
        return "\(dateString) [\(level)] \(message) \(metadataString)\n"
    }
}

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

