//
//  File.swift
//  SwiftLogger
//
//  Created by Sion on 2026/3/19.
//

import Foundation
import SwiftLogger

public final class SizeRotatingFileLogHandler: RotatingFileLogHandler, @unchecked Sendable {
    
    public typealias RotatingOptions = UInt64
    
    public var label: String
    
    public var logLevel = Logger.Level.info
    
    public var prettyMetadata: String?
    
    public var options: RotatingOptions

    public var path: String
    
    public var logIndex: UInt = 0
    
    public var max: UInt?
    
    public var maxSize: UInt64 { return options }
    
    public var encoding: String.Encoding
    
    public var stream: FileStream?
        
    /// Minimum and maximum intervals for adaptive draining
    public var minFlushInterval: TimeInterval = 0.1
    public var maxFlushInterval: TimeInterval = 5.0
    private var currentFlushInterval: TimeInterval
    
    public var queue: DispatchQueue
    private let queueKey = DispatchSpecificKey<Void>()
    private var drainTimer: DispatchSourceTimer?

    public var metadata = Logger.Metadata() {
        didSet {
            prettyMetadata = prettify(metadata)
        }
    }
    
    public init(label: String, path: String, encoding: String.Encoding, options: RotatingOptions, max: UInt?) {
        self.label = label
        self.path = path
        self.encoding = encoding
        self.options = options
        self.max = max
        self.queue = DispatchQueue(label: "\(label).size.rotating.file.log.handler")
        self.queue.setSpecific(key: queueKey, value: ())

        self.currentFlushInterval = 1
        
        self.stream = FileOutputStream(path: "\(self.path).\(self.logIndex)")

        // start periodic drain timer on the handler queue (adaptive)
        let timer = DispatchSource.makeTimerSource(queue: self.queue)
        timer.schedule(deadline: .now() + self.currentFlushInterval, repeating: self.currentFlushInterval)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            let logs = TLSBufferManager.shared.drainAll()
            if logs.isEmpty {
                // back off when idle
                self.currentFlushInterval = Swift.min(self.maxFlushInterval, Swift.max(self.minFlushInterval, self.currentFlushInterval * 2))
            } else {
                // reset to aggressive interval when activity seen
                self.currentFlushInterval = self.minFlushInterval
                self.writeBatch(logs)
            }
            // reschedule with new interval
            timer.schedule(deadline: .now() + self.currentFlushInterval, repeating: self.currentFlushInterval)
        }
        timer.resume()
        self.drainTimer = timer
    }
    
    deinit {
        // cancel periodic timer
        drainTimer?.setEventHandler {}
        drainTimer?.cancel()

        // final drain: collect logs from all thread-local buffers and write them
        let logs = TLSBufferManager.shared.drainAll()
        if !logs.isEmpty {
            if DispatchQueue.getSpecific(key: queueKey) != nil {
                // already on handler queue
                self.writeBatch(logs)
            } else {
                self.queue.sync {
                    self.writeBatch(logs)
                }
            }
        }

        stream?.flush()
        stream?.close()
    }
    
    public func rotate(data: Data) -> String? {
        guard let stream = self.stream else { return nil }
        let size = UInt64(data.count)
        guard stream.writedSize + size > maxSize else { return nil }
        
        if size > maxSize {
            print("data is larger than maximum byte size allowed per file rotation (\(size) > \(maxSize))")
        }
        logIndex += 1
        return "\(self.path).\(self.logIndex)"
    }
}
