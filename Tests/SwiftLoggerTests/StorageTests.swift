import Testing
import Foundation
@testable import SwiftLogger

@Suite("Logger.Storage Tests")
struct StorageTests {

    // A minimal mock LogHandler for testing Storage
    private struct MockHandler: LogHandler {
        var metadataProvider: Logger.MetadataProvider?
        var metadata: Logger.Metadata = [:]
        var logLevel: Logger.Level = .info

        func log(level: Logger.Level,
                 message: Logger.Message,
                 metadata: Logger.Metadata?,
                 source: String,
                 file: String,
                 function: String,
                 line: UInt) {
            // No-op
        }

        subscript(metadataKey _: String) -> Logger.Metadata.Value? {
            get { nil }
            set { }
        }
    }

    @Test("Storage: Initialization")
    func testInitialization() {
        let label = "test-label"
        let handler = MockHandler()
        let storage = Logger.Storage(label: label, handler: handler)
        
        #expect(storage.label == label)
        #expect(storage.handler is MockHandler)
    }

    @Test("Storage: Property access and modification")
    func testPropertyAccess() {
        let storage = Logger.Storage(label: "initial", handler: MockHandler())
        
        storage.label = "updated"
        #expect(storage.label == "updated")
        
        let newHandler = MockHandler()
        storage.handler = newHandler
        #expect(storage.handler is MockHandler)
    }

    @Test("Storage: Copying")
    func testCopy() {
        let label = "original"
        let handler = MockHandler()
        let storage = Logger.Storage(label: label, handler: handler)
        
        let copiedStorage = storage.copy()
        
        // Verify it's a new instance with same values
        #expect(copiedStorage !== storage)
        #expect(copiedStorage.label == storage.label)
        #expect(copiedStorage.handler is MockHandler)
        
        // Verify changes to one don't affect the other
        storage.label = "changed"
        #expect(copiedStorage.label == "original")
    }
}
