//
// StdioOutputStream.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2026/1/5
//

import Foundation

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
        let systemStderr = Darwin.stderr
        return StdioOutputStream(file: systemStderr, flushMode: .always)
    }()
    internal static let stdout = {
        let systemStdout = Darwin.stdout
        return StdioOutputStream(file: systemStdout, flushMode: .always)
    }()

    internal enum FlushMode {
        case undefined
        case always
    }
}