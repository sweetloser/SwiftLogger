//
// Logger.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2025/12/31
//

public struct Logger {

    @usableFromInline
    internal var _storage: Logger.Storage
    public var label: String { return self._storage.label }

    @inlinable
    public var handler: any LogHandler {
        get { return self._storage.hanler }
        set {
            if !isKnownUniquelyReferenced(&self._storage) {
                self._storage = self._storage.copy()
            }
            self._storage.hanler = newValue
        }
    }

    @usableFromInline
    internal init(label: String, handler: any LogHandler) {
        self._storage = Logger.Storage(label: label, hanler: handler)
    }
}

extension Logger {
    @inlinable
    public func log(level: Logger.Level, _ message: @autoclosure () -> Logger.Message, metadata: @autoclosure () -> Logger.Metadata? = nil, source
    : @autoclosure () -> String? = nil, file: String = #fileID, function: String = #function, line: UInt = #line) {
        if self.logLevel <= level {
            self.handler.log(level: level, message: message(), metadata: metadata(), source: source() ?? Logger.currentModule(fileID: (file)), file: file, function: function, line: line)
        }
    }

    @inlinable
    public func log(level: Logger.Level, _ message: @autoclosure () -> Logger.Message, metadata: @autoclosure () -> Logger.Metadata? = nil, file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: level, message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }

    @inlinable
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            self.handler[metadataKey: key]
        }
        set {
            self.handler[metadataKey: key] = newValue
        }
    }

    @inlinable
    public var logLevel: Logger.Level {
        get {
            self.handler.logLevel
        }
        set {
            self.handler.logLevel = newValue
        }
    }

}