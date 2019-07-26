//
//  CardProject.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/02/2018.
//

import SwiftyJSON

public struct CardProductSummary: Equatable {
  public let id: String
  public let name: String?
  public let countries: [Country]?
}

public enum CardProductStatus: String {
  case enabled
  case disabled
}

public struct CardProduct {
  public let id: String
  public let teamId: String
  public let name: String
  public let summary: String?
  public let website: String?
  public let cardholderAgreement: Content?
  public let privacyPolicy: Content?
  public let termsAndConditions: Content?
  public let faq: Content?
  public let status: CardProductStatus
  public let shared: Bool
  public let disclaimerAction: WorkflowAction
  public let cardIssuer: String
  public let waitListBackgroundImage: String?
  public let waitListBackgroundColor: String?
  public let waitListAsset: String?
}

extension JSON {
  var cardProductSummary: CardProductSummary? {
    guard let id = self["id"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse CardProductSummary \(self)"))
      return nil
    }

    let name = self["name"].string
    var countries: [Country]? = nil
    if let countryCodes = self["allowed_countries"].arrayObject as? [String] {
      countries = countryCodes.map { Country(isoCode: $0) }
    }
    return CardProductSummary(id: id, name: name, countries: countries)
  }
}
