//
// LoggingSystem.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2026/1/5
//

import Foundation

public enum LoggingSystem {
    
    private static let _factory = FactoryBox( {label, _ in StreamLogHandler.standardError(label: label) }, violationErrorMessage: "logging system can be only initialized once per progress.")

    private static let _metadataProviderFactory = MetadataProviderBox(nil, violationErrorMessage: "logging system can only be initialized once per progress.")

    @preconcurrency
    public static func bootstrap(_ factory: @escaping @Sendable (String) -> any LogHandler) {
        self._factory.replace({label, _ in factory(label) }, validate: true)
    }

    @preconcurrency
    public static func bootstrap(_ factory: @escaping @Sendable (String, Logger.MetadataProvider?) -> any LogHandler, metadataProvider: Logger.MetadataProvider?) {
        self._metadataProviderFactory.replace(metadataProvider, validate: true)
        self._factory.replace(factory, validate: true)
    }

    public static var metadataProvider: Logger.MetadataProvider? {
        self._metadataProviderFactory.underlying
    }

    final class RWLockedValueBox<Value: Sendable>: @unchecked Sendable {
        private let lock = ReadWriteLock()
        private  var storage: Value

        init(initialValue: Value) {
            self.storage = initialValue
        }

        func withReadLock<Result>(_ operation: (Value) -> Result) -> Result {
            self.lock.withReaderLock { operation(self.storage) }
        }

        func withWriteLock<Result>(_ operation: (inout Value) -> Result) -> Result {
            self.lock.withWriterLock { operation(&self.storage) }
        }
    }

    private struct ReplaceOnceBox<BoxedType: Sendable> {
        private struct ReplaceOnce: Sendable {
            private var initialized = false
            private var _underlying: BoxedType
            private let violationErrorMessage: String

            mutating func replaceUnderlying(_ underlying: BoxedType, validate: Bool) {
                precondition(!validate || !self.initialized, self.violationErrorMessage)
                self._underlying = underlying
                self.initialized = true
            }

            var underlying: BoxedType {
                return self._underlying
            }

            init(underlying: BoxedType, violationErrorMessage: String) {
                self._underlying = underlying
                self.violationErrorMessage = violationErrorMessage
            }
        }

        private let storage: RWLockedValueBox<ReplaceOnce>

        init(_ underlying: BoxedType, violationErrorMessage: String) {
            self.storage = RWLockedValueBox(initialValue: ReplaceOnce(underlying: underlying, violationErrorMessage: violationErrorMessage))
        }

        func replace(_ newUnderlying: BoxedType, validate: Bool) {
            self.storage.withWriteLock { $0.replaceUnderlying(newUnderlying, validate: validate) }
        }

        var underlying: BoxedType {
            return self.storage.withReadLock { $0.underlying }
        }
    }
    
    private typealias FactoryBox = ReplaceOnceBox< @Sendable (_ lable: String, _ provider: Logger.MetadataProvider) -> any LogHandler>

    private typealias MetadataProviderBox = ReplaceOnceBox<Logger.MetadataProvider?>
}