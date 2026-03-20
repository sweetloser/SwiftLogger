//
// Storage.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2025/12/31
//

extension Logger {
    @usableFromInline
    internal final class Storage: @unchecked Sendable { 
        @usableFromInline 
        var label: String

        @usableFromInline
        var handler: any LogHandler

        @inlinable
        init(label: String, handler: any LogHandler) {
            self.label = label
            self.handler = handler
        }

        @inlinable
        func copy() -> Storage {
            return Storage(label: self.label, handler: self.handler)
        }
    }
}