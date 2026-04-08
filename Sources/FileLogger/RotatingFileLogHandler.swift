//
//  RotatingFileLogHandler.swift
//  SwiftLogger
//
//  Created by Sion on 2026/3/19.
//

import Foundation
import SwiftLogger

public protocol RotatingFileLogHandler: AnyObject, FileHandler {
    
    associatedtype RotatingOptions: Hashable
    
    var path: String { get }

    var logIndex: UInt { get set }
    
    var options: RotatingOptions { get }

    var max: UInt? { get }

    var queue: DispatchQueue { get }
        
    func rotate(data: Data) -> String?

    init(label: String, path: String, encoding: String.Encoding, options: RotatingOptions, max: UInt?)
}


extension RotatingFileLogHandler {
    public func log(level: Logger.Level,
                     message: Logger.Message,
                     metadata: Logger.Metadata?,
                     source: String,
                     file: String,
                     function: String,
                     line: UInt) {
        let data = self.buildMessage(level: level, message: message, metadata: metadata, file: file, function: function, line: line)

        let ts = Date().timeIntervalSinceReferenceDate
        let seq = TLSBufferManager.shared.nextSequence()
        let entry = LogEntry(timestamp: ts, seq: seq, data: data)

        let buffer = TLSBufferManager.shared.currentBuffer()
        if buffer.append(entry) {
            flush()
        }
    }
    
    private func flush() {
        // When a single thread's buffer reaches capacity, collect entries from
        // all thread-local buffers (and any pending destructor buffers) to
        // ensure no entries are left behind and global ordering is preserved.
        queue.async { [weak self] in
            guard let self = self else { return }
            let logs = TLSBufferManager.shared.drainAll()
            guard !logs.isEmpty else { return }
            self.writeBatch(logs)
        }
    }
    
    func writeBatch(_ logs: [LogEntry]) {
        // sort by timestamp then seq to ensure global chronological order
        let sorted = logs.sorted { a, b in
            if a.timestamp == b.timestamp {
                return a.seq < b.seq
            }
            return a.timestamp < b.timestamp
        }

        for entry in sorted {
            let data = entry.data
            if let newLogPath = rotate(data: data) {
                self.stream?.rotate(to: newLogPath)
            }
            stream?.write(data)
        }
        stream?.flush()
    }
}
