import Foundation

/// A log entry stored in thread-local buffers before being written to file.
internal struct LogEntry {
    let timestamp: TimeInterval
    let seq: UInt64
    let data: Data
}
