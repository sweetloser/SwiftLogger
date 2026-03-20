import Testing
import Foundation
@testable import SwiftLogger

@Suite("StdioOutputStream Tests")
struct StdioOutputStreamTests {

    @Test("StdioOutputStream: Static instances")
    func testStaticInstances() {
        // Ensure stdout and stderr are initialized
        let _ = StdioOutputStream.stdout
        let _ = StdioOutputStream.stderr
    }

    @Test("StdioOutputStream: Write to stdout")
    func testWriteToStdout() {
        let stream = StdioOutputStream.stdout
        // We can't easily capture actual stdout in a unit test without redirecting file descriptors,
        // but we can verify it doesn't crash.
        stream.write("Test log to stdout\n")
    }

    @Test("StdioOutputStream: Write to stderr")
    func testWriteToStderr() {
        let stream = StdioOutputStream.stderr
        stream.write("Test log to stderr\n")
    }

    @Test("StdioOutputStream: Continuous UTF8 conversion")
    func testContinuousUTF8() {
        let stream = StdioOutputStream.stdout
        let testString = "Hello, 🌍!"
        let utf8View = stream.continousUTF8(testString)
        
        #expect(String(utf8View) == testString)
    }

    @Test("StdioOutputStream: Flush functionality")
    func testFlush() {
        let stream = StdioOutputStream.stdout
        // Calling flush should not crash
        stream.flush()
    }
    
    @Test("StdioOutputStream: Custom file pointer (Temporary File)")
    func testCustomFileStream() throws {
        // Create a temporary file to test writing
        let tempFilePath = NSTemporaryDirectory() + "test_stdio_output.txt"
        guard let filePointer = fopen(tempFilePath, "w") else {
            Issue.record("Failed to open temporary file")
            return
        }
        
        defer {
            fclose(filePointer)
            try? FileManager.default.removeItem(atPath: tempFilePath)
        }
        
        let stream = StdioOutputStream(file: filePointer, flushMode: .always)
        let testMessage = "Hello Temporary File!"
        stream.write(testMessage)
        
        // Ensure data is flushed to disk
        stream.flush()
        
        // Read back and verify
        let content = try String(contentsOfFile: tempFilePath, encoding: .utf8)
        #expect(content == testMessage)
    }
}
