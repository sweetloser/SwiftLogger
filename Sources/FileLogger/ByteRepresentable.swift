//
//  File.swift
//  SwiftLogger
//
//  Created by Sion on 2026/3/19.
//

import Foundation

public protocol ByteRepresentable {
    var bytes: Int { get }
}

public extension ByteRepresentable {
    var kilobytes: Int { return bytes * 1024 }
    var kb: Int { return kilobytes }
    
    var megabytes: Int { return kilobytes * 1024 }
    var mb: Int { return megabytes }

    var gigabytes: Int { return megabytes * 1024 }
    var gb: Int { return gigabytes }

    var terabytes: Int { return gigabytes * 1024 }
    var tb: Int { return terabytes }

    var petabytes: Int { return terabytes * 1024 }
    var pb: Int { return petabytes }
}

extension Int: ByteRepresentable {
    public var bytes: Int { return self }
}
extension Int64: ByteRepresentable {
    public var bytes: Int { return Int(self) }
}
extension Float: ByteRepresentable {
    public var bytes: Int { return Int(self) }
}
extension Double: ByteRepresentable {
    public var bytes: Int { return Int(self) }
}
