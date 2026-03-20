import Testing
import Foundation
@testable import SwiftLogger

@Suite("LoggingSystem Tests")
struct LoggingSystemTests {
    @Test("LoggingSystem: bootstrap sets factory and metadataProvider")
    func testBootstrapFactoryAndMetadataProvider() {
        #expect(LoggingSystem.metadataProvider == nil)

        let beforeLogger = Logger(label: "before")
        let beforeHandler = beforeLogger.handler as? StreamLogHandler
        #expect(beforeHandler != nil)
        #expect(beforeHandler?.metadataProvider == nil)

        let provider = Logger.MetadataProvider { ["k": "v"] }
        LoggingSystem.bootstrap({ label, metadataProvider in
            var handler = StreamLogHandler.standardError(label: label, metadataProvider: metadataProvider)
            handler.logLevel = .trace
            return handler
        }, metadataProvider: provider)

        let systemProvider = LoggingSystem.metadataProvider
        #expect(systemProvider?.get()["k"]?.description == "v")

        let afterLogger = Logger(label: "after")
        let afterHandler = afterLogger.handler as? StreamLogHandler
        #expect(afterHandler?.label == "after")
        #expect(afterHandler?.logLevel == .trace)
        #expect(afterHandler?.metadataProvider?.get()["k"]?.description == "v")
    }
}

