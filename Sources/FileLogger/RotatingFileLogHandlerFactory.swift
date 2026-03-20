//
//  RotatingFileLogHandlerFactory.swift
//  SwiftLogger
//
//  Created by Sion on 2026/3/19.
//

import Foundation
import SwiftLogger

public final class RotatingFileLogHandlerFactory<Handler: RotatingFileLogHandler>: @unchecked Sendable {
    public var encoding: String.Encoding
    public var path: String
    public var options: Handler.RotatingOptions
    public var max: UInt?
    
    public init(path: String, options: Handler.RotatingOptions, encoding: String.Encoding = .utf8, max: UInt? = nil) {
        self.path = path
        self.encoding = encoding
        self.options = options
        self.max = max
    }
    
    public func makeRotatingFileLogHandler(label: String) -> Handler {
        Handler.init(label: label, path: self.path, encoding: self.encoding, options: self.options, max: max)
    }
}
