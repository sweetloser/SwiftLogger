import Testing
import Foundation
@testable import SwiftLogger

@Suite("Logger.MetadataValue Tests")
struct MetadataTests {

    @Test("MetadataValue: String literal initialization")
    func testStringLiteral() {
        let value: Logger.MetadataValue = "test-string"
        if case .string(let str) = value {
            #expect(str == "test-string")
        } else {
            Issue.record("Expected .string case")
        }
        #expect(value.description == "test-string")
    }

    @Test("MetadataValue: String interpolation initialization")
    func testStringInterpolation() {
        let count = 42
        let value: Logger.MetadataValue = "count is \(count)"
        #expect(value.description == "count is 42")
    }

    @Test("MetadataValue: Dictionary literal initialization")
    func testDictionaryLiteral() {
        let value: Logger.MetadataValue = ["key1": "value1", "key2": "value2"]
        #expect(value.description.contains("key1"))
        #expect(value.description.contains("value1"))
        #expect(value.description.contains("key2"))
        #expect(value.description.contains("value2"))
    }

    @Test("MetadataValue: Array literal initialization")
    func testArrayLiteral() {
        let value: Logger.MetadataValue = ["item1", "item2"]
        #expect(value.description.contains("item1"))
        #expect(value.description.contains("item2"))
    }

    @Test("MetadataValue: CustomStringConvertible initialization")
    func testStringConvertible() {
        struct MyCustom: CustomStringConvertible, Sendable {
            var description: String { "custom-desc" }
        }
        let value = Logger.MetadataValue.stringConvertible(MyCustom())
        #expect(value.description == "custom-desc")
    }

    @Test("MetadataValue: Nested structures")
    func testNestedMetadata() {
        let nestedArray: Logger.MetadataValue = ["a", "b"]
        let nestedDict: Logger.MetadataValue = ["innerKey": "innerValue"]
        
        let complex: Logger.MetadataValue = [
            "list": nestedArray,
            "map": nestedDict,
            "simple": "val"
        ]
        
        let desc = complex.description
        #expect(desc.contains("list"))
        #expect(desc.contains("map"))
        #expect(desc.contains("innerValue"))
        #expect(desc.contains("val"))
    }
}
