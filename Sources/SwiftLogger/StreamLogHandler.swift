//
// StreamLogHandler.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2026/1/5
//

import Foundation

public struct StreamLogHandler: LogHandler {
    internal typealias _SendableTextOutputStream = TextOutputStream & Sendable

    public static func standardOutput(label: String) -> StreamLogHandler {
        StreamLogHandler(label: label, stream: StdioOutputStream.stdout)
    }
    public static func standardOutput(label: String, metadataProvider: Logger.MetadataProvider?) -> StreamLogHandler {
        StreamLogHandler(label: label, stream: StdioOutputStream.stdout,  metadataProvider: metadataProvider)
    }
    public static func standardError(label: String) -> StreamLogHandler {
        StreamLogHandler(label: label, stream: StdioOutputStream.stderr)
    }
    public static func standardError(label: String, metadataProvider: Logger.MetadataProvider?) -> StreamLogHandler {
        StreamLogHandler(label: label, stream: StdioOutputStream.stderr, metadataProvider: metadataProvider)
    }

    private let stream: _SendableTextOutputStream
    public let label: String

    public var logLevel: Logger.Level = .info

    public var metadataProvider: Logger.MetadataProvider?
    private var prettyMetadata: String?
    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }

    public subscript(metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata explicitMetadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        let effectiveMetadata = StreamLogHandler.prepareMetadata(base: self.metadata, provider: self.metadataProvider, explicit: explicitMetadata)

        let prettyMetadata: String?
        if let effectiveMetadata = effectiveMetadata {
            prettyMetadata = self.prettify(effectiveMetadata)
        } else {
            prettyMetadata = self.prettyMetadata
        }

        var stream = self.stream
        stream.write("\(self.timestamp()) \(level)\(self.label.isEmpty ? "" : " ")\(self.label):\(prettyMetadata.map { " \($0)"} ?? "") [\(source)] \(message)\n")
    }

    internal static func prepareMetadata(base: Logger.Metadata, provider: Logger.MetadataProvider?, explicit: Logger.Metadata?) -> Logger.Metadata? {
        var metadata = base

        let provided = provider?.get() ?? [:]

        guard !provided.isEmpty || !((explicit ?? [:]).isEmpty) else {
            return nil
        }

        if !provided.isEmpty {
            metadata.merge(provided, uniquingKeysWith: { _, provided in provided })
        }

        if let explicit = explicit, !explicit.isEmpty {
            metadata.merge(explicit, uniquingKeysWith: { _, explicit in explicit })
        }

        return metadata
    }


    private func timestamp() -> String {
        var buffer = [UInt8](repeating: 0, count: 256)
        var timestamp = time(nil)
        guard let localTime = localtime(&timestamp) else {
            return "<unknown>"
        }
        strftime(&buffer, buffer.count, "%Y-%m-%d %H:%M:%S", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        if metadata.isEmpty {
            return nil
        } else {
            return metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: " ")
        }
    }

    internal init(label: String, stream: any _SendableTextOutputStream) {
        self.init(label: label, stream: stream, metadataProvider: LoggingSystem.metadataProvider)
    }
    internal init(label: String, stream: any _SendableTextOutputStream, metadataProvider: Logger.MetadataProvider?) {
        self.label = label
        self.stream = stream
        self.metadataProvider = metadataProvider
    }
}

