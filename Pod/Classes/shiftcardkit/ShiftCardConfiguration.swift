//
//  ShiftCardConfiguration.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/02/2018.
//

enum ShiftCardProductStatus: String {
  case enabled
  case disabled
}

struct ShiftCardProduct {
  let id: String
  let teamId: String
  let name: String
  let summary: String?
  let website: String?
  let cardholderAgreement: Content?
  let privacyPolicy: Content?
  let termsAndConditions: Content?
  let faq: Content?
  let status: ShiftCardProductStatus
  let shared: Bool
  let disclaimerAction: WorkflowAction
  let cardIssuer: String
}

class ShiftCardConfiguration {
  let posMode = false // TODO: Remove when clear the goal of this property
  let cardProduct: ShiftCardProduct
  var features: [ShiftCardOptionsKeys: Bool] = [:]

  init(cardProduct: ShiftCardProduct) {
    self.cardProduct = cardProduct
  }

  func isFeatureEnabled(_ feature: ShiftCardOptionsKeys) -> Bool {
    guard let enabledFeature = features[feature] else {
      return false
    }
    return enabledFeature
  }
}
