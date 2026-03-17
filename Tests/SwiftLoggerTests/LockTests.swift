import Testing
import Foundation
@testable import SwiftLogger

@Suite("Lock Tests")
struct LockTests {

    private final class ProtectedCounter: @unchecked Sendable {
        var value = 0
    }

    @Test("Lock: Initialization")
    func testLockInitialization() {
        // If initialization fails, it will trigger a precondition failure (crash)
        let _ = Lock()
    }

    @Test("Lock: Basic locking and unlocking")
    func testLockBasic() {
        let lock = Lock()
        lock.lock()
        // Critical section
        lock.unlock()
    }

    @Test("Lock: withLock functionality")
    func testWithLock() {
        let lock = Lock()
        var value = 0
        let result = lock.withLock {
            value += 1
            return "success"
        }
        #expect(value == 1)
        #expect(result == "success")
    }

    @Test("Lock: withLockVoid functionality")
    func testWithLockVoid() {
        let lock = Lock()
        var value = 0
        lock.withLockVoid {
            value += 1
        }
        #expect(value == 1)
    }

    @Test("Lock: Concurrent access stress test")
    func testLockConcurrency() async {
        let lock = Lock()
        let counter = ProtectedCounter()
        let iterations = 1000
        let taskCount = 10

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<taskCount {
                group.addTask {
                    for _ in 0..<iterations {
                        lock.withLock {
                            counter.value += 1
                        }
                    }
                }
            }
        }

        #expect(counter.value == taskCount * iterations)
    }
}

@Suite("ReadWriteLock Tests")
struct ReadWriteLockTests {

    private final class ProtectedCounter: @unchecked Sendable {
        var value = 0
    }

    @Test("ReadWriteLock: Initialization")
    func testReadWriteLockInitialization() {
        // If initialization fails, it will trigger a precondition failure (crash)
        let _ = ReadWriteLock()
    }

    @Test("ReadWriteLock: Basic reader locking")
    func testReaderLock() {
        let lock = ReadWriteLock()
        lock.withReaderLock {
            // Read access
        }
    }

    @Test("ReadWriteLock: Basic writer locking")
    func testWriterLock() {
        let lock = ReadWriteLock()
        lock.withWriterLock {
            // Write access
        }
    }

    @Test("ReadWriteLock: Reader locking with multiple readers")
    func testMultipleReaders() async {
        let lock = ReadWriteLock()
        let iterations = 100
        let readerCount = 10

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<readerCount {
                group.addTask {
                    for _ in 0..<iterations {
                        lock.withReaderLock {
                            // Ensure multiple readers can enter without deadlocking
                        }
                    }
                }
            }
        }
    }

    @Test("ReadWriteLock: Writer exclusivity")
    func testWriterExclusivity() async {
        let lock = ReadWriteLock()
        let counter = ProtectedCounter()
        let iterations = 1000
        let writerCount = 5

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<writerCount {
                group.addTask {
                    for _ in 0..<iterations {
                        lock.withWriterLock {
                            counter.value += 1
                        }
                    }
                }
            }
        }

        #expect(counter.value == writerCount * iterations)
    }

    @Test("ReadWriteLock: withReaderLockVoid functionality")
    func testWithReaderLockVoid() {
        let lock = ReadWriteLock()
        var value = 0
        lock.withReaderLockVoid {
            value += 1
        }
        #expect(value == 1)
    }

    @Test("ReadWriteLock: withWriterLockVoid functionality")
    func testWithWriterLockVoid() {
        let lock = ReadWriteLock()
        var value = 0
        lock.withWriterLockVoid {
            value += 1
        }
        #expect(value == 1)
    }

    @Test("ReadWriteLock: Mixed read and write stress test")
    func testMixedReadWrite() async {
        let lock = ReadWriteLock()
        let counter = ProtectedCounter()
        let iterations = 500
        let readerCount = 5
        let writerCount = 2

        await withTaskGroup(of: Void.self) { group in
            // Writers
            for _ in 0..<writerCount {
                group.addTask {
                    for _ in 0..<iterations {
                        lock.withWriterLock {
                            counter.value += 1
                        }
                    }
                }
            }

            // Readers
            for _ in 0..<readerCount {
                group.addTask {
                    for _ in 0..<iterations {
                        lock.withReaderLock {
                            _ = counter.value
                        }
                    }
                }
            }
        }

        #expect(counter.value == writerCount * iterations)
    }
}
