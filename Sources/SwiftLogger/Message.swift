//
// Message.swift
// SwiftLogger
//
// Created by zengxiangxiang on 2026/1/4
//

import Foundation

extension Logger {
    public struct Message: ExpressibleByStringLiteral, Equatable, CustomStringConvertible, ExpressibleByStringInterpolation {

        public typealias StringLiteralType = String

        private var value: String

        public init(stringLiteral value: String) {
            self.value = value
        }

        public init(stringInterpolation: DefaultStringInterpolation) {
            self.value = stringInterpolation.description
        }

        public var description: String {
            return self.value
        }
    }
}

// MARK: - Sendable support helpers.
extension Logger.Message: Sendable {}
