//
// Lock.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2026/1/4
//

import Foundation

package final class Lock: @unchecked Sendable {
    fileprivate let mutex: UnsafeMutablePointer<pthread_mutex_t> = UnsafeMutablePointer.allocate(capacity: 1)

    init() {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, .init(PTHREAD_MUTEX_ERRORCHECK))

        let error = pthread_mutex_init(mutex, &attr)
        precondition(error == 0, "\(#function) failed to initialize mutex with error \(error)")
    }

    deinit {
        let error = pthread_mutex_destroy(self.mutex)
        precondition(error == 0, "\(#function) failed to destroy mutex with error \(error)")
        mutex.deallocate()
    }

    package func lock() {
        let error = pthread_mutex_lock(self.mutex)
        precondition(error == 0, "\(#function) failed to lock mutex with error \(error)")
    }

    package func unlock() {
        let error = pthread_mutex_unlock(self.mutex)
        precondition(error == 0, "\(#function) failed to unlock mutex with error \(error)")
    }
}

extension Lock {
    
    @inlinable
    package func withLock<T>(_ body : () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }
        return try body()
    }

    @inlinable
    package func withLockVoid(_ body : () throws -> Void) rethrows {
        try self.withLock(body)
    }
}

internal final class ReadWriteLock: @unchecked Sendable { 
    fileprivate let rwlock: UnsafeMutablePointer<pthread_rwlock_t> = UnsafeMutablePointer.allocate(capacity: 1)

    public init() {
        let error = pthread_rwlock_init(rwlock, nil)
        precondition(error == 0, "\(#function) failed to initialize rwlock with error \(error)")
    }
    deinit {
        let error = pthread_rwlock_destroy(self.rwlock)
        precondition(error == 0, "\(#function) failed to destroy rwlock with error \(error)")
        self.rwlock.deallocate()
    }

    fileprivate func lockRead() {
        let error = pthread_rwlock_rdlock(self.rwlock)
        precondition(error == 0, "\(#function) failed to read lock rwlock with error \(error)")
    }

    fileprivate func lockWrite() {
        let error = pthread_rwlock_wrlock(self.rwlock)
        precondition(error == 0, "\(#function) failed to write lock rwlock with error \(error)")
    }

    fileprivate func unlock() {
        let error = pthread_rwlock_unlock(self.rwlock)
        precondition(error == 0, "\(#function) failed to unlock rwlock with error \(error)")
    }
}

extension ReadWriteLock {
    
    @inlinable
    internal func withReaderLock<T>(_ body : () throws -> T) rethrows -> T {
        self.lockRead()
        defer { self.unlock() }
        return try body()
    }

    @inlinable
    internal func withWriterLock<T>(_ body : () throws -> T) rethrows -> T {
        self.lockWrite()
        defer { self.unlock() }
        return try body()
    }

    @inlinable
    internal func withReaderLockVoid(_ body : () throws -> Void) rethrows {
        try self.withReaderLock(body)
    }

    @inlinable
    internal func withWriterLockVoid(_ body : () throws -> Void) rethrows {
        try self.withWriterLock(body)
    }
}
