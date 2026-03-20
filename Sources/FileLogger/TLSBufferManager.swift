//
//  TLSBufferManager.swift
//  SwiftLogger
//
import Foundation

internal final class TLSBufferManager: @unchecked Sendable {
    static let shared = TLSBufferManager()

    private let key = UnsafeMutablePointer<pthread_key_t>.allocate(capacity: 1)
    private let defaultBufferCapacity = 100

    private let buffersLock = NSLock()
    private var buffers = NSHashTable<AnyObject>.weakObjects()

    // pending buffers pushed from thread destructor
    private let pendingLock = NSLock()
    private var pending: [[LogEntry]] = []

    // global sequence counter for tie-breaking
    private let seqLock = NSLock()
    private var seqCounter: UInt64 = 0

    private init() {
        pthread_key_create(key) { _ in
            // The destructor receives the thread-specific value (the ThreadLocalBuffer pointer).
            // Call the shared manager to handle the thread-exit collection.
            TLSBufferManager.shared.threadDestroyed()
        }
    }

    deinit {
        pthread_key_delete(key.pointee)
    }

    private func threadDestroyed() {
        guard let ptr = pthread_getspecific(key.pointee) else { return }

        // We used `Unmanaged.passRetained` when setting the thread-specific value in
        // `currentBuffer()`. Here we must consume that retained reference using
        // `takeRetainedValue()` so the object can be deallocated normally.
        let tlb = Unmanaged<ThreadLocalBuffer>.fromOpaque(ptr).takeRetainedValue()
        let logs = tlb.takeAll()
        if !logs.isEmpty {
            appendPending(logs)
        }
    }

    func currentBuffer() -> ThreadLocalBuffer {
        if let ptr = pthread_getspecific(key.pointee) {
            let box = Unmanaged<AnyObject>.fromOpaque(ptr).takeUnretainedValue()
            return box as! ThreadLocalBuffer
        }

        let buf = ThreadLocalBuffer(capacity: defaultBufferCapacity)
        let unmanaged = Unmanaged.passRetained(buf)
        pthread_setspecific(key.pointee, unmanaged.toOpaque())

        buffersLock.lock()
        buffers.add(buf)
        buffersLock.unlock()

        return buf
    }

    func appendPending(_ logs: [LogEntry]) {
        pendingLock.lock()
        pending.append(logs)
        pendingLock.unlock()
    }

    func drainAll() -> [LogEntry] {
        var result: [LogEntry] = []

        // collect from live buffers
        buffersLock.lock()
        for case let obj as ThreadLocalBuffer in buffers.allObjects {
            let logs = obj.takeAll()
            if !logs.isEmpty {
                result.append(contentsOf: logs)
            }
        }
        buffersLock.unlock()

        // collect pending from destructors
        pendingLock.lock()
        let pend = pending
        pending.removeAll(keepingCapacity: true)
        pendingLock.unlock()

        for p in pend {
            result.append(contentsOf: p)
        }

        return result
    }

    func nextSequence() -> UInt64 {
        seqLock.lock()
        seqCounter &+= 1
        let v = seqCounter
        seqLock.unlock()
        return v
    }
}
