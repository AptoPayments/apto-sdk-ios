//
//  MonthlyStatementsPeriod.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 01/10/2019.
//

import Foundation
import SwiftyJSON

public struct Month: Equatable {
    public let month: Int
    public let year: Int

    public init(month: Int, year: Int) {
        self.month = month
        self.year = year
    }

    public init(from date: Date) {
        month = date.month
        year = date.year
    }

    public func toDate() -> Date? {
        return Calendar.current.date(from: DateComponents(year: year, month: month))
    }
}

public struct MonthlyStatementsPeriod: Equatable {
    public let start: Month
    public let end: Month

    public init(start: Month, end: Month) {
        self.start = start
        self.end = end
    }

    public func availableMonths() -> [Month] {
        guard var date = start.toDate(), let endDate = end.toDate()?.add(1, units: .day) else { return [] }
        var months = [Month]()
        while endDate.isGreaterThanDate(date) {
            months.append(Month(month: date.month, year: date.year))
            date = date.add(1, units: .month)! // swiftlint:disable:this force_unwrapping
        }
        return months
    }

    public func includes(month: Month) -> Bool {
        guard let date = month.toDate(), let startDate = start.toDate(), let endDate = end.toDate() else { return false }
        return startDate <= date && date <= endDate
    }
}

extension JSON {
    var month: Month? {
        guard let month = self["month"].int, let year = self["year"].int else {
            ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                  reason: "Can't parse Month \(self)"))
            return nil
        }
        return Month(month: month, year: year)
    }

    var monthlyStatementsPeriod: MonthlyStatementsPeriod? {
        guard let start = self["start"].month, let end = self["end"].month else {
            ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                  reason: "Can't parse MonthlyStatementsPeriod \(self)"))
            return nil
        }
        return MonthlyStatementsPeriod(start: start, end: end)
    }
}
