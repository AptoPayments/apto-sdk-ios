//
//  Merchant.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 17/08/16.
//
//

import Foundation

let mccDescriptions: [String: String] = [
  "plane": "transaction_details.basic_info.category.plane_mcc",
  "car": "transaction_details.basic_info.category.car_mcc",
  "glass": "transaction_details.basic_info.category.glass_mcc",
  "finance": "transaction_details.basic_info.category.finance_mcc",
  "food": "transaction_details.basic_info.category.food_mcc",
  "gas": "transaction_details.basic_info.category.gas_mcc",
  "bed": "transaction_details.basic_info.category.bed_mcc",
  "medical": "transaction_details.basic_info.category.medical_mcc",
  "camera": "transaction_details.basic_info.category.camera_mcc",
  "card": "transaction_details.basic_info.category.card_mcc",
  "cart": "transaction_details.basic_info.category.cart_mcc",
  "road": "transaction_details.basic_info.category.road_mcc",
  "other": "transaction_details.basic_info.category.other_mcc"
]

@objc open class MCC: NSObject, Codable {
  let code: String?
  let name: String
  public let icon: MCCIcon

  init(code: String?, name: String, icon: MCCIcon) {
    self.code = code
    self.name = name
    self.icon = icon
  }

  public func description() -> String {
    if let value = mccDescriptions[icon.rawValue] {
      return value.podLocalized()
    }
    return "transaction_details.basic_info.category.unavailable".podLocalized()
  }
}

@objc open class Merchant: NSObject, Codable {
  public let id: String?
  open var merchantKey: String?
  public let name: String?
  public let mcc: MCC?

  public init(id: String?, merchantKey: String?, name: String?, mcc: MCC?) {
    self.id = id
    self.merchantKey = merchantKey
    self.name = name
    self.mcc = mcc
  }
}
