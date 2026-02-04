//
// MetadataProvider.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2025/12/31
//

import Foundation

@preconcurrency protocol _SwiftLogSendable: Sendable {}

extension Logger {
    public struct MetadataProvider: _SwiftLogSendable {
        @usableFromInline
        internal let _provideMetadata: @Sendable () -> Metadata

        public init(_ provideMetadata: @escaping @Sendable () -> Metadata) {
            self._provideMetadata = provideMetadata
        }
        
        public func get() -> Metadata {
            return _provideMetadata()
        }
    }

    public static func multiplex(_ providers: [Logger.MetadataProvider]) -> Logger.MetadataProvider? {
        assert(!providers.isEmpty, "providers should not be empty!")
        return Logger.MetadataProvider {
            providers.reduce(into: [:]) { metadata, provider in
                let providedMetadata = provider.get()
                guard !providedMetadata.isEmpty else {
                    return
                }

                // 重复key以最后一个为准
                metadata.merge(providedMetadata, uniquingKeysWith: { _ , rhs in rhs })
            }
        }
    }
}