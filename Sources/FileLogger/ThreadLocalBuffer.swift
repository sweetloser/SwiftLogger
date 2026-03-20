//
//+  ThreadLocalBuffer.swift
//  SwiftLogger

//
//  ThreadLocalBuffer.swift
//  SwiftLogger
//
//  Created by Sion on 2026/3/20.
//

import Foundation

internal final class ThreadLocalBuffer {
    private var storage: [LogEntry] = []
    private let capacity: Int
    private let lock = NSLock()

    init(capacity: Int) {
        self.capacity = capacity
        self.storage.reserveCapacity(capacity)
    }

    /// Append data to the buffer. Returns true if buffer reached capacity.
    @discardableResult
    func append(_ entry: LogEntry) -> Bool {
        lock.lock()
        storage.append(entry)
        let reached = storage.count >= capacity
        lock.unlock()
        return reached
    }

    /// Take all items out of the buffer in a thread-safe manner.
    /// This uses a swap technique to minimize time spent holding the lock.
    func takeAll() -> [LogEntry] {
        lock.lock()
        let current = storage
        storage = []
        lock.unlock()
        return current
    }

    var isEmpty: Bool {
        lock.lock()
        let empty = storage.isEmpty
        lock.unlock()
        return empty
    }
}
