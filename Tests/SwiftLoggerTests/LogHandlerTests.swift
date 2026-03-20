import Testing
import Foundation
@testable import SwiftLogger

@Suite("LogHandler Tests")
struct LogHandlerTests {

    // A mock LogHandler to test the protocol requirements and default implementations
    final class MockLogHandler: LogHandler, @unchecked Sendable {
        var metadataProvider: Logger.MetadataProvider?
        var metadata: Logger.Metadata = [:]
        var logLevel: Logger.Level = .info
        
        var loggedMessages: [(level: Logger.Level, message: Logger.Message)] = []
        private let lock = NSLock()

        func log(level: Logger.Level,
                 message: Logger.Message,
                 metadata: Logger.Metadata?,
                 source: String,
                 file: String,
                 function: String,
                 line: UInt) {
            lock.lock()
            defer { lock.unlock() }
            loggedMessages.append((level, message))
        }

        subscript(metadataKey key: String) -> Logger.Metadata.Value? {
            get {
                lock.lock()
                defer { lock.unlock() }
                return metadata[key]
            }
            set {
                lock.lock()
                defer { lock.unlock() }
                metadata[key] = newValue
            }
        }
    }

    @Test("LogHandler: Basic logging")
    func testLogHandlerBasic() {
        let handler = MockLogHandler()
        handler.log(level: .info, message: "test message", metadata: nil, source: "test-source", file: "test-file", function: "test-func", line: 42)
        
        #expect(handler.loggedMessages.count == 1)
        #expect(handler.loggedMessages[0].level == .info)
        #expect(handler.loggedMessages[0].message.description == "test message")
    }

    @Test("LogHandler: Log level management")
    func testLogLevelManagement() {
        let handler = MockLogHandler()
        handler.logLevel = .error
        #expect(handler.logLevel == .error)
        
        handler.logLevel = .debug
        #expect(handler.logLevel == .debug)
    }

    @Test("LogHandler: Metadata management via subscript")
    func testMetadataManagement() {
        let handler = MockLogHandler()
        handler[metadataKey: "user"] = "sion"
        #expect(handler[metadataKey: "user"]?.description == "sion")
        
        handler[metadataKey: "user"] = nil
        #expect(handler[metadataKey: "user"] == nil)
    }

    @Test("LogHandler: Default metadataProvider implementation")
    func testDefaultMetadataProvider() {
        struct DefaultLogHandler: LogHandler {
            var metadata: Logger.Metadata = [:]
            var logLevel: Logger.Level = .info

            func log(level: Logger.Level,
                     message: Logger.Message,
                     metadata: Logger.Metadata?,
                     source: String,
                     file: String,
                     function: String,
                     line: UInt) { }

            subscript(metadataKey key: String) -> Logger.Metadata.Value? {
                get { metadata[key] }
                set { metadata[key] = newValue }
            }
        }

        var handler = DefaultLogHandler()
        // The protocol extension provides a default getter/setter for metadataProvider
        #expect(handler.metadataProvider == nil)
        
        // Testing that setting it doesn't crash even if the default implementation is empty
        handler.metadataProvider = Logger.MetadataProvider { [:] }
        #expect(handler.metadataProvider == nil) // default implementation returns nil
    }
}
