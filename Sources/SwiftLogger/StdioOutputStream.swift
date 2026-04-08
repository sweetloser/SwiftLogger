//
// StdioOutputStream.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2026/1/5
//

import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

internal typealias CFilePointer = UnsafeMutablePointer<FILE>

internal struct StdioOutputStream: TextOutputStream, @unchecked Sendable {
    
    internal let file: CFilePointer
    internal let flushMode: FlushMode


    internal func write(_ string: String) {
        self.continousUTF8(string).withContiguousStorageIfAvailable { utf8Bytes in
            flockfile(self.file)
            defer { funlockfile(self.file) }
            _ = fwrite(utf8Bytes.baseAddress, 1, utf8Bytes.count, self.file)
            if case .always = self.flushMode {
                self.flush()
            }
        }!
    }
    internal func flush() {
        _ = fflush(self.file)
    }
    internal func continousUTF8(_ string: String) -> String.UTF8View {
        var continousString = string
        continousString.makeContiguousUTF8()
        return continousString.utf8
    }

    internal static let stderr = {
        guard let file = fdopen(dup(STDERR_FILENO), "a") else {
            fatalError("failed to open duplicated stderr stream")
        }
        return StdioOutputStream(file: file, flushMode: .always)
    }()
    internal static let stdout = {
        guard let file = fdopen(dup(STDOUT_FILENO), "a") else {
            fatalError("failed to open duplicated stdout stream")
        }
        return StdioOutputStream(file: file, flushMode: .always)
    }()

    internal enum FlushMode {
        case undefined
        case always
    }
}
