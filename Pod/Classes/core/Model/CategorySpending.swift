//
// CategorySpending.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 08/01/2019.
//

import Foundation
import SwiftyJSON

public struct CategorySpending: Codable {
  public let categoryId: MCCIcon
  public let spending: Amount
  public let difference: Double?
}

public struct MonthlySpending: Codable {
  public let previousSpendingExists: Bool
  public let nextSpendingExists: Bool
  public let spending: [CategorySpending]
  public var date: Date?
}

extension JSON {
  var categorySpending: CategorySpending? {
    guard let rawCategoryId = self["category_id"].string,
          let spending = self["spending"].amount else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse CategorySpending \(self)"))
      return nil
    }
    let categoryId = MCCIcon.from(iconName: rawCategoryId)
    let difference = self["difference"].double
    return CategorySpending(categoryId: categoryId, spending: spending, difference: difference)
  }

  var monthlySpending: MonthlySpending? {
    guard let previousSpendingExists = self["prev_spending_exists"].bool,
          let nextSpendingExists = self["next_spending_exists"].bool,
          let spendingData = self["spending"]["data"].array else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse MonthlySpending \(self)"))
      return nil
    }
    let spending: [CategorySpending] = spendingData.compactMap { return $0.categorySpending }

    return MonthlySpending(previousSpendingExists: previousSpendingExists,
                           nextSpendingExists: nextSpendingExists,
                           spending: spending,
                           date: nil)
  }
}
