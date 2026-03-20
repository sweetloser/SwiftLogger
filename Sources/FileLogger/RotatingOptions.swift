//
//  RotatingOptions.swift
//  SwiftLogger
//
//  Created by Sion on 2026/3/19.
//

import Foundation

private let _calendar = Calendar.current
private let secondsPerMinute = UInt(_calendar.maximumRange(of: .second)?.upperBound ?? 60)
private let minutesPerHour = UInt(_calendar.maximumRange(of: .minute)?.upperBound ?? 60)
private let hoursPerDay = UInt(_calendar.maximumRange(of: .hour)?.upperBound ?? 24)
private let daysPerWeek = UInt(_calendar.maximumRange(of: .day)?.upperBound ?? 7)
private let secondsPerDay = secondsPerMinute * minutesPerHour * hoursPerDay

private extension Calendar {
    func startOfMinute(for date: Date) -> Date {
        return self.date(bySetting: .minute, value: 0, of: date)!
    }
    func startOfHour(for date: Date) -> Date {
        return self.date(bySetting: .hour, value: 0, of: date)!
    }
    func startOfWeek(for date: Date) -> Date {
    
        let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        guard let startOfWeekDate = self.date(from: components) else {
            // calendar calculation failed, return the start of day as a fallback.
            return self.startOfDay(for: date)
        }
        return startOfWeekDate
    }
    func startOfMonth(for date: Date) -> Date {
        return self.date(bySetting: .day, value: 1, of: startOfDay(for: date))!
    }

    func startOfYear(for date: Date) -> Date {
        return self.date(bySetting: .month, value: 1, of: startOfMonth(for: date))!
    }

    func nextStartOfMinute(from date: Date) -> Date {
        return self.date(byAdding: .minute, value: 1, to: startOfMinute(for: date))!
    }
    func nextStartOfHour(from date: Date) -> Date {
        return self.date(byAdding: .hour, value: 1, to: startOfHour(for: date))!
    }
    func nextStartOfDay(from date: Date) -> Date {
        return self.date(byAdding: .day, value: 1, to: startOfDay(for: date))!
    }
    func nextStartOfWeek(from date: Date) -> Date {
        return self.date(byAdding: .day, value: Int(daysPerWeek), to: startOfWeek(for: date))!
    }
    func nextStartOfMonth(from date: Date) -> Date {
        return self.date(byAdding: .month, value: 1, to: startOfMonth(for: date))!
    }
    func nextStartOfYear(from date: Date) -> Date {
        return self.date(byAdding: .year, value: 1, to: startOfYear(for: date))!
    }
}

public enum DateRotateOption: Hashable, Sendable {
    case seconds(UInt)
    case minutes(UInt)
    case hours(UInt)
    case days(UInt)
    case weeks(UInt)
    case months(UInt)
    case years(UInt)
    
    public static let hourly = DateRotateOption.hours(1)
    public static let daily = DateRotateOption.days(1)
    public static let weekly = DateRotateOption.weeks(1)
    public static let monthly = DateRotateOption.months(1)
    public static let yearly = DateRotateOption.years(1)

    var format: String {
        switch self {
        case .seconds: return "yyyy-MM-dd HH:mm:ss"
        case .minutes, .hours: return "yyyy-MM-dd HH:mm"
        case .days, .weeks: return "yyyy-MM-dd"
        case .months: return "yyyy-MM"
        case .years: return "yyyy"
        }
    }

    func range() -> Range<Date> {
        let start: Date
        let end: Date
        switch self {
        case .seconds(let seconds):
            start = Date()
            end = _calendar.date(byAdding: .second, value: Int(seconds), to: start)!
        case .minutes(let minutes):
            start = _calendar.startOfMinute(for: Date())
            end = _calendar.date(byAdding: .minute, value: Int(minutes), to: start)!
        case .hours(let hours):
            start = _calendar.startOfHour(for: Date())
            end = _calendar.date(byAdding: .hour, value: Int(hours), to: start)!
        case .days(let days):
            start = _calendar.startOfDay(for: Date())
            end = _calendar.date(byAdding: .day, value: Int(days), to: start)!
        case .weeks(let weeks):
            start = _calendar.startOfWeek(for: Date())
            end = _calendar.date(byAdding: .day, value: Int(weeks * daysPerWeek), to: start)!
        case .months(let months):
            start = _calendar.startOfMonth(for: Date())
            end = _calendar.date(byAdding: .month, value: Int(months), to: start)!
        case .years(let years):
            start = _calendar.startOfYear(for: Date())
            end = _calendar.date(byAdding: .year, value: Int(years), to: start)!
        }

        return start..<end
    }
}

public extension BinaryInteger {
    private var unit: UInt { return UInt(self) }

    var seconds: DateRotateOption { return .seconds(unit) }
    var minutes: DateRotateOption { return .minutes(unit) }
    var hours: DateRotateOption { return .hours(unit) }
    var days: DateRotateOption { return .days(unit) }
    var weeks: DateRotateOption { return .weeks(unit) }
    var months: DateRotateOption { return .months(unit) }
    var years: DateRotateOption { return .years(unit) }
}
