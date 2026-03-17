//
// Logger.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2025/12/31
//

import Foundation

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
    
    @inlinable
    public var metadataProvider: Logger.MetadataProvider? {
        self.handler.metadataProvider
    }
    
    @usableFromInline
    internal init(label: String, _ handler: any LogHandler) {
        self._storage = Logger.Storage(label: label, handler: handler)
    }
}

extension Logger {
    public init(label: String) {
        self.init(label: label, LoggingSystem.factory(label, LoggingSystem.metadataProvider))
    }
    
    public init(label: String, factory: (String) -> any LogHandler) {
        self = Logger.init(label: label, factory(label))
    }
    
    public init(label: String, factory: (String, Logger.MetadataProvider?) -> any LogHandler) {
        self = Logger.init(label: label, factory(label, LoggingSystem.metadataProvider))
    }
    
    public init(label: String, metadataProvider: MetadataProvider) {
        self = Logger.init(label: label, factory: { label in
            var handler = LoggingSystem.factory(label, metadataProvider)
            handler.metadataProvider = metadataProvider
            return handler
        })
    }
}


extension Logger {
    @inlinable
    public func log(level: Logger.Level,
                    _ message: @autoclosure () -> Logger.Message,
                    metadata: @autoclosure () -> Logger.Metadata? = nil,
                    file: String = #fileID,
                    function: String = #function,
                    line: UInt = #line) {
        self.log(level: level, message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }
    
    @inlinable
    public func log(level: Logger.Level,
                    _ message: @autoclosure () -> Logger.Message,
                    metadata: @autoclosure () -> Logger.Metadata? = nil,
                    source: @autoclosure () -> String? = nil,
                    file: String = #fileID,
                    function: String = #function,
                    line: UInt = #line) {
    }
    
    @inlinable
    package func _log(level: Logger.Level,
                      _ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        if self.logLevel <= level {
            self.handler.log(level: level, message: message(), metadata: metadata(), source: source() ?? Logger.currentModule(fileID: file), file: file, function: function, line: line)
        }
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

extension Logger {
    @inlinable
    public func trace(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        #if !MaxLogLevelDebug && !MaxLogLevelInfo && !MaxLogLevelNotice && !MaxLogLevelWarning && !MaxLogLevelError && !MaxLogLevelCritical && !MaxLogLevelNone
        self._log(level: .trace, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
        #endif
    }
    @inlinable
    public func trace(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        self.trace(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }
    
    @inlinable
    public func debug(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        #if !MaxLogLevelInfo && !MaxLogLevelNotice && !MaxLogLevelWarning && !MaxLogLevelError && !MaxLogLevelCritical && !MaxLogLevelNone
        self._log(level: .debug, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
        #endif
    }
    @inlinable
    public func debug(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        self.debug(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }
    
    @inlinable
    public func info(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        #if !MaxLogLevelNotice && !MaxLogLevelWarning && !MaxLogLevelError && !MaxLogLevelCritical && !MaxLogLevelNone
        self._log(level: .info, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
        #endif
    }
    @inlinable
    public func info(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        self.info(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }
    
    @inlinable
    public func notice(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        #if !MaxLogLevelWarning && !MaxLogLevelError && !MaxLogLevelCritical && !MaxLogLevelNone
        self._log(level: .notice, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
        #endif
    }
    @inlinable
    public func notice(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        self.notice(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }
    
    @inlinable
    public func warning(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        #if !MaxLogLevelError && !MaxLogLevelCritical && !MaxLogLevelNone
        self._log(level: .warning, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
        #endif
    }
    @inlinable
    public func warning(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        self.warning(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }
    
    @inlinable
    public func error(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        #if !MaxLogLevelCritical && !MaxLogLevelNone
        self._log(level: .error, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
        #endif
    }
    @inlinable
    public func error(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        self.error(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }
    
    @inlinable
    public func critical(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        #if !MaxLogLevelNone
        self._log(level: .critical, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
        #endif
    }
    @inlinable
    public func critical(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      file: String = #fileID,
                      function: String = #function,
                      line: UInt = #line) {
        self.critical(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }
}

extension Logger {
    @inlinable
    internal static func currentModule(filePath: String = #file) -> String {
        let utf8All = filePath.utf8
        return filePath.utf8.lastIndex(of: UInt8(ascii: "/")).flatMap { lastSlash -> Substring? in
            utf8All[..<lastSlash].lastIndex(of: UInt8(ascii: "/")).map { secondSlash -> Substring in
                filePath[utf8All.index(after: secondSlash)..<lastSlash]
            }
        }.map { String($0) } ?? "n/a"
    }
    @inlinable
    internal static func currentModule(fileID: String = #fileID) -> String {
        let utf8All = fileID.utf8
        if let slashIndex = utf8All.firstIndex(of: UInt8(ascii: "/")) {
            return String(fileID[..<slashIndex])
        } else {
            return "n/a"
        }
    }
}

// MARK: - Sendable support helpers.
extension Logger: Sendable {}
