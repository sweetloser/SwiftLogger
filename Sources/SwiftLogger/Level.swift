//
// Level.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2025/12/31
//

extension Logger {
    public enum Level: String, Codable, CaseIterable {
        case trace
        case debug
        case info
        case notice
        case warning
        case error
        case critical
    }
}