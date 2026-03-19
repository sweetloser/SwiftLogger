//
//  File.swift
//  SwiftLogger
//
//  Created by Sion on 2026/3/19.
//

import Foundation
import SwiftLogger

public final class SizeRotatingFileLogHandler: RotatingFileLogHandler, @unchecked Sendable {
    
    public typealias RotatingOptions = UInt64
    
    public var options: RotatingOptions

    public var path: String
    
    public var logIndex: UInt = 0
    
    public var max: UInt?
    
    public var maxSize: UInt64 { return options }
    
    public func archivedFileURLs() throws -> [URL] {
        return []
    }
    
    public var encoding: String.Encoding
    
    public var label: String
    
    public var logLevel = Logger.Level.info
    
    public var prettyMetadata: String?
    
    public var stream: FileStream?
    
    public var metadata = Logger.Metadata() {
        didSet {
            prettyMetadata = prettify(metadata)
        }
    }
    
    public init(label: String, path: String, encoding: String.Encoding, options: RotatingOptions, max: UInt?) {
        self.label = label
        self.path = path
        self.encoding = encoding
        self.options = options
        
        self.stream = FileOutputStream(path: "\(self.path).\(self.logIndex)")
    }
    
    public func rotate(data: Data) -> String? {
        guard let stream = self.stream else { return nil }
        let size = UInt64(data.count)
        guard stream.writedSize + size > maxSize else { return nil }
        
        if size <= maxSize {
            print("data is larger than maximum byte size allowed per file rotation (\(size) > \(maxSize))")
        }
        logIndex += 1
        return "\(self.path).\(self.logIndex)"
    }
}
