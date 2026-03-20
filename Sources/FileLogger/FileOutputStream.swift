
//
// FileOutputStream.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2026/1/5
//

import Foundation
import SwiftLogger

internal typealias CFilePointer = UnsafeMutablePointer<FILE>

internal class FileOutputStream: FileStream, @unchecked Sendable {
    
    var writedSize: UInt64
    
    private var file: CFilePointer?
    
    init?(path: String) {
        guard let file = fopen(path, "a") else {
            return nil
        }
        self.file = file
        
        self.writedSize = UInt64(ftello(file))
    }
    
    func rotate(to newPath: String) {
        close()
        guard let file = fopen(newPath, "a") else {
            return
        }
        
        self.file = file
        
        self.writedSize = UInt64(ftello(file))
    }
    
    internal func close() {
        guard let file = self.file else { return }
        fclose(file)
        self.file = nil
    }
    
    internal func write(_ data: Data) {
        guard let file = self.file else { return }
        let dataSize = UInt64(data.count)
        data.withUnsafeBytes { bytes in
            flockfile(file)
            defer { funlockfile(file) }
            _ = fwrite(bytes.baseAddress, 1, bytes.count, file)
        }
        writedSize += dataSize
    }
    
    internal func flush() {
        guard let file = self.file else { return }
        _ = fflush(file)
    }
    
    private func continousUTF8(_ string: String) -> String.UTF8View {
        var continousString = string
        continousString.makeContiguousUTF8()
        return continousString.utf8
    }
}
