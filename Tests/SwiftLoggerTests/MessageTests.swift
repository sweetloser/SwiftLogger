import Testing
import Foundation
@testable import SwiftLogger

@Suite("Logger.Message Tests")
struct MessageTests {

    @Test("Message: Initialization from string literal")
    func testInitializationFromLiteral() {
        let message: Logger.Message = "Hello, world!"
        #expect(message.description == "Hello, world!")
    }

    @Test("Message: Equality - Ensure two messages with same content are equal")
    func testEquality() {
        let msg1: Logger.Message = "Test Message"
        let msg2: Logger.Message = "Test Message"
        let msg3: Logger.Message = "Different Message"
        
        #expect(msg1 == msg2)
        #expect(msg1 != msg3)
    }

    @Test("Message: CustomStringConvertible - Verify description")
    func testDescription() {
        let content = "Logging content"
        let message: Logger.Message = Logger.Message(stringLiteral: content)
        #expect(message.description == content)
        #expect("\(message)" == content)
    }

    @Test("Message: ExpressibleByStringInterpolation - Verify string interpolation")
    func testStringInterpolation() {
        let name = "Sion"
        let age = 20
        let message: Logger.Message = "User: \(name), Age: \(age)"
        #expect(message.description == "User: Sion, Age: 20")
    }
}
