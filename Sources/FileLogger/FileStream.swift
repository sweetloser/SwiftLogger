//
//  File.swift
//  SwiftLogger
//
//  Created by Sion on 2026/3/19.
//

import Foundation

public protocol FileStream {
    
    var writedSize: UInt64 { get set }
    
    func write(_ data: Data)
    
    func rotate(to newPath: String)
}
