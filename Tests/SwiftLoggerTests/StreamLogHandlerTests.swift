import Testing
import Foundation
@testable import SwiftLogger

@Suite("StreamLogHandler Tests")
struct StreamLogHandlerTests {

    // A simple sendable TextOutputStream for testing
    final class TestStream: TextOutputStream, @unchecked Sendable {
        private var _contents = ""
        var contents: String {
            lock.lock()
            defer { lock.unlock() }
            return _contents
        }

        private let lock = NSLock()

        func write(_ string: String) {
            lock.lock()
            defer { lock.unlock() }
            _contents += string
        }
    }

    @Test("StreamLogHandler: Basic logging")
    func testBasicLogging() {
        let stream = TestStream()
        var handler = StreamLogHandler(label: "test", stream: stream, metadataProvider: nil)
        handler.logLevel = .info
        
        handler.log(level: .info, message: "hello", metadata: nil, source: "src", file: "file", function: "func", line: 1)
        
        let output = stream.contents  // 需要把 TestStream 的 contents 改为 internal 或提供读取方法
        #expect(output.contains("info"))
        #expect(output.contains("test"))
        #expect(output.contains("[src]"))
        #expect(output.contains("hello"))
    }

    @Test("StreamLogHandler: Metadata merging")
    func testMetadataMerging() {
        let stream = TestStream()
        
        // 1. Base metadata
        var handler = StreamLogHandler(label: "test", stream: stream, metadataProvider: nil)
        handler.metadata = ["base": "val1"]
        
        // 2. Metadata from provider
        let provider = Logger.MetadataProvider { ["provided": "val2"] }
        handler.metadataProvider = provider
        
        // 3. Explicit metadata in log call
        handler.log(level: .info, message: "msg", metadata: ["explicit": "val3"], source: "src", file: "file", function: "func", line: 1)
        
        let output = stream.contents
        #expect(output.contains("base=val1"))
        #expect(output.contains("provided=val2"))
        #expect(output.contains("explicit=val3"))
    }

    @Test("StreamLogHandler: Metadata priority (explicit overrides all)")
    func testMetadataPriority() {
        let stream = TestStream()
        let provider = Logger.MetadataProvider { ["key": "provider"] }
        var handler = StreamLogHandler(label: "test", stream: stream, metadataProvider: provider)
        handler.metadata = ["key": "base"]
        
        handler.log(level: .info, message: "msg", metadata: ["key": "explicit"], source: "src", file: "file", function: "func", line: 1)
        
        #expect(stream.contents.contains("key=explicit"))
        #expect(!stream.contents.contains("key=provider"))
        #expect(!stream.contents.contains("key=base"))
    }

    @Test("StreamLogHandler: Static convenience methods")
    func testStaticMethods() {
        let _ = StreamLogHandler.standardOutput(label: "stdout")
        let _ = StreamLogHandler.standardError(label: "stderr")
        
        let provider = Logger.MetadataProvider { [:] }
        let _ = StreamLogHandler.standardOutput(label: "stdout-p", metadataProvider: provider)
        let _ = StreamLogHandler.standardError(label: "stderr-p", metadataProvider: provider)
    }

    @Test("StreamLogHandler: Subscript access")
    func testSubscript() {
        let stream = TestStream()
        var handler = StreamLogHandler(label: "test", stream: stream, metadataProvider: nil)
        
        handler[metadataKey: "newKey"] = "newValue"
        #expect(handler.metadata["newKey"]?.description == "newValue")
        #expect(handler[metadataKey: "newKey"]?.description == "newValue")
    }
}
