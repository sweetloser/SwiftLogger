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

extension Logger.Level {
    internal var naturalIntegralValue: Int {
        switch self {
        case .trace:
            return 0
        case .debug:
            return 1
        case .info:
            return 2
        case .notice:
            return 3
        case .warning:
            return 4
        case .error:
            return 5
        case .critical:
            return 6
        }
    }
}

extension Logger.Level: Comparable {
    public static func < (lhs: Logger.Level, rhs: Logger.Level) -> Bool {
        lhs.naturalIntegralValue < rhs.naturalIntegralValue
    }
}

extension Logger.Level: CustomStringConvertible, LosslessStringConvertible {
    public var description: String {
        self.rawValue
    }
    
    public init?(_ description: String) {
        self.init(rawValue: description.lowercased())
    }
    
    
}
