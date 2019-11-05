//
// MonthlyStatementReport.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/09/2019.
//

import Foundation
import SwiftyJSON

public class MonthlyStatementReport: NSObject {
  @objc public let id: String
  @objc public let month: Int
  @objc public let year: Int
  @objc public let downloadUrl: String?
  @objc public let urlExpirationDate: Date?

  @objc public init(id: String, month: Int, year: Int, downloadUrl: String?, urlExpirationDate: Date?) {
    self.id = id
    self.month = month
    self.year = year
    self.downloadUrl = downloadUrl
    self.urlExpirationDate = urlExpirationDate
    super.init()
  }
}

extension JSON {
  var monthlyStatementReport: MonthlyStatementReport? {
    guard let id = self["id"].string, let month = self["month"].int, let year = self["year"].int else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse MonthlyStatementReport \(self)"))
      return nil
    }
    let downloadUrl = self["download_url"].string
    var urlExpirationDate: Date?
    if let urlExpiration = self["url_expiration"].string {
      urlExpirationDate = Date.dateFromISO8601(string: urlExpiration)
    }
    return MonthlyStatementReport(id: id, month: month, year: year, downloadUrl: downloadUrl,
                                  urlExpirationDate: urlExpirationDate)
  }
}
