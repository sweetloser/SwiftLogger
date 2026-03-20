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

extension Logger.MetadataValue: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension Logger.MetadataValue: ExpressibleByStringInterpolation {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self = .string(stringInterpolation.description)
    }
}

extension Logger.MetadataValue: ExpressibleByDictionaryLiteral {
    
    public typealias Key = String
    public typealias Value = Logger.Metadata.Value
    
    public init(dictionaryLiteral elements: (String, Logger.Metadata.Value)...) {
        self = .dictionary(.init(uniqueKeysWithValues: elements))
    }
}

extension Logger.MetadataValue: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = Logger.Metadata.Value
    
    public init(arrayLiteral elements: Logger.Metadata.Value...) {
        self = .array(elements)
    }
}

extension Logger.MetadataValue: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .string(let string):
            return string
        case .stringConvertible(let repr):
            return repr.description
        case .dictionary(let dict):
            return dict.mapValues { $0.description }.description
        case .array(let array):
            return array.map { $0.description }.description
        }
    }
}

// MARK: - Sendable support helpers.
extension Logger.MetadataValue: Sendable {}
