import Testing
import Foundation
@testable import SwiftLogger

@Suite("Logger Tests")
struct LoggerTests {

    // A struct-based mock LogHandler to test COW and value semantics
    struct MockLogHandler: LogHandler {
        var metadataProvider: Logger.MetadataProvider?
        var metadata: Logger.Metadata = [:]
        var logLevel: Logger.Level = .info
        
        struct LogEvent {
            let level: Logger.Level
            let message: Logger.Message
            let metadata: Logger.Metadata?
            let source: String
        }

        private final class EventStorage: @unchecked Sendable {
            var events: [LogEvent] = []
            let lock = NSLock()
        }
        private let eventStorage = EventStorage()

        var logEvents: [LogEvent] {
            eventStorage.lock.withLock { eventStorage.events }
        }

        func log(level: Logger.Level,
                 message: Logger.Message,
                 metadata: Logger.Metadata?,
                 source: String,
                 file: String,
                 function: String,
                 line: UInt) {
            eventStorage.lock.withLock {
                eventStorage.events.append(LogEvent(level: level, message: message, metadata: metadata, source: source))
            }
        }

        subscript(metadataKey key: String) -> Logger.Metadata.Value? {
            get { metadata[key] }
            set { metadata[key] = newValue }
        }
    }

    @Test("Logger: Initialization with factory")
    func testLoggerInitializationWithFactory() {
        let label = "test-label"
        let handler = MockLogHandler()
        let logger = Logger(label: label) { _ in handler }
        
        #expect(logger.label == label)
        #expect(logger.handler is MockLogHandler)
    }

    @Test("Logger: Log level filtering")
    func testLogLevelFiltering() {
        let handler = MockLogHandler()
        var logger = Logger(label: "test") { _ in handler }
        
        logger.logLevel = .info
        
        // Log at higher level
        logger.error("error message")
        #expect(handler.logEvents.count == 1)
        #expect(handler.logEvents.last?.level == .error)
        
        // Log at same level
        logger.info("info message")
        #expect(handler.logEvents.count == 2)
        #expect(handler.logEvents.last?.level == .info)
        
        // Log at lower level (should be filtered)
        logger.debug("debug message")
        #expect(handler.logEvents.count == 2)
    }

    @Test("Logger: Convenience methods (info, error, etc.)")
    func testConvenienceMethods() {
        let handler = MockLogHandler()
        var logger = Logger(label: "test") { _ in handler }
        logger.logLevel = .trace
        
        logger.trace("trace")
        logger.debug("debug")
        logger.info("info")
        logger.notice("notice")
        logger.warning("warning")
        logger.error("error")
        logger.critical("critical")
        
        #expect(handler.logEvents.count == 7)
        #expect(handler.logEvents[0].level == .trace)
        #expect(handler.logEvents[1].level == .debug)
        #expect(handler.logEvents[2].level == .info)
        #expect(handler.logEvents[3].level == .notice)
        #expect(handler.logEvents[4].level == .warning)
        #expect(handler.logEvents[5].level == .error)
        #expect(handler.logEvents[6].level == .critical)
    }

    @Test("Logger: Metadata management")
    func testMetadataManagement() {
        let handler = MockLogHandler()
        var logger = Logger(label: "test") { _ in handler }
        
        logger[metadataKey: "user-id"] = "123"
        #expect(logger[metadataKey: "user-id"]?.description == "123")
        logger.info("msg", metadata: ["request-id": "abc"])
        #expect(handler.logEvents.last?.metadata?["request-id"]?.description == "abc")
    }

    @Test("Logger: Value semantics (copy-on-write)")
    func testValueSemantics() {
        let handler1 = MockLogHandler()
        let logger1 = Logger(label: "test") { _ in handler1 }
        
        var logger2 = logger1
        // Initially they should have the same metadata
        #expect(logger1[metadataKey: "key"] == nil)
        #expect(logger2[metadataKey: "key"] == nil)
        
        // Modifying metadata should trigger copy-on-write
        logger2[metadataKey: "key"] = "val"
        
        // logger1 should NOT be affected
        #expect(logger1[metadataKey: "key"] == nil)
        #expect(logger2[metadataKey: "key"]?.description == "val")
    }
    
    @Test("Logger: Source calculation")
    func testSourceCalculation() {
        let handler = MockLogHandler()
        let logger = Logger(label: "test") { _ in handler }
        
        logger.info("test message")
        
        // Expected source is the module name of the test file
        // Depending on build system, it might be "SwiftLoggerTests"
        let source = handler.logEvents.last?.source
        #expect(source != nil)
        #expect(source != "n/a")
    }
}

// Helper extension for MockLogHandler to use NSLock easily
extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        self.lock()
        defer { self.unlock() }
        return body()
    }
}
