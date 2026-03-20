import Testing
import Foundation
@testable import SwiftLogger

@Suite("Logger.MetadataProvider Tests")
struct MetadataProviderTests {

    @Test("MetadataProvider: Initialization and basic get()")
    func testBasicProvider() {
        let provider = Logger.MetadataProvider {
            ["user-id": "123", "session-id": "abc"]
        }
        
        let metadata = provider.get()
        #expect(metadata.count == 2)
        #expect(metadata["user-id"]?.description == "123")
        #expect(metadata["session-id"]?.description == "abc")
    }

    @Test("MetadataProvider: Multiplexing multiple providers")
    func testMultiplexing() {
        let provider1 = Logger.MetadataProvider {
            ["source": "auth", "common": "val1"]
        }
        let provider2 = Logger.MetadataProvider {
            ["target": "db", "common": "val2"] // Should override provider1's common key
        }
        
        guard let multiplexed = Logger.multiplex([provider1, provider2]) else {
            Issue.record("Multiplexed provider should not be nil")
            return
        }
        
        let metadata = multiplexed.get()
        #expect(metadata.count == 3)
        #expect(metadata["source"]?.description == "auth")
        #expect(metadata["target"]?.description == "db")
        #expect(metadata["common"]?.description == "val2") // Last one wins
    }

    @Test("MetadataProvider: Multiplexing with empty results")
    func testMultiplexingEmpty() {
        let provider1 = Logger.MetadataProvider { [:] }
        let provider2 = Logger.MetadataProvider { ["key": "value"] }
        
        guard let multiplexed = Logger.multiplex([provider1, provider2]) else {
            Issue.record("Multiplexed provider should not be nil")
            return
        }
        
        let metadata = multiplexed.get()
        #expect(metadata.count == 1)
        #expect(metadata["key"]?.description == "value")
    }
}
