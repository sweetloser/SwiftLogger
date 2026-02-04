//
// Metadata.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2025/12/31
//

extension Logger {
    public typealias Metadata = [String: MetadataValue]

    public enum MetadataValue {
        case string(String)
        case stringConvertible(CustomStringConvertible & Sendable)
        case dictionary(Metadata)
        case array([Metadata.Value])
    }
}