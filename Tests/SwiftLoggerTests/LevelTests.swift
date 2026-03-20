import Testing
import Foundation
@testable import SwiftLogger

@Suite("Logger.Level Tests")
struct LevelTests {

    @Test("Level: CaseIterable - Ensure all cases exist")
    func testCaseIterable() {
        let allCases = Logger.Level.allCases
        #expect(allCases.count == 7)
        #expect(allCases.contains(.trace))
        #expect(allCases.contains(.debug))
        #expect(allCases.contains(.info))
        #expect(allCases.contains(.notice))
        #expect(allCases.contains(.warning))
        #expect(allCases.contains(.error))
        #expect(allCases.contains(.critical))
    }

    @Test("Level: Comparable - Verify correct ordering")
    func testComparable() {
        #expect(Logger.Level.trace < .debug)
        #expect(Logger.Level.debug < .info)
        #expect(Logger.Level.info < .notice)
        #expect(Logger.Level.notice < .warning)
        #expect(Logger.Level.warning < .error)
        #expect(Logger.Level.error < .critical)
        
        #expect(Logger.Level.critical > .error)
        #expect(Logger.Level.info >= .info)
        #expect(Logger.Level.debug <= .debug)
    }

    @Test("Level: CustomStringConvertible - description matches rawValue")
    func testDescription() {
        #expect(Logger.Level.trace.description == "trace")
        #expect(Logger.Level.debug.description == "debug")
        #expect(Logger.Level.info.description == "info")
        #expect(Logger.Level.notice.description == "notice")
        #expect(Logger.Level.warning.description == "warning")
        #expect(Logger.Level.error.description == "error")
        #expect(Logger.Level.critical.description == "critical")
    }

    @Test("Level: LosslessStringConvertible - init from string")
    func testInitializationFromString() {
        #expect(Logger.Level("trace") == .trace)
        #expect(Logger.Level("DEBUG") == .debug)
        #expect(Logger.Level("Info") == .info)
        #expect(Logger.Level("notice") == .notice)
        #expect(Logger.Level("WARNING") == .warning)
        #expect(Logger.Level("Error") == .error)
        #expect(Logger.Level("critical") == .critical)
        
        #expect(Logger.Level("invalid") == nil)
        #expect(Logger.Level("") == nil)
    }

    @Test("Level: Codable - JSON encoding and decoding")
    func testCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let level = Logger.Level.warning
        let data = try encoder.encode(level)
        
        // JSON string should be "warning"
        let jsonString = String(data: data, encoding: .utf8)
        #expect(jsonString == "\"warning\"")
        
        let decodedLevel = try decoder.decode(Logger.Level.self, from: data)
        #expect(decodedLevel == level)
    }
}
