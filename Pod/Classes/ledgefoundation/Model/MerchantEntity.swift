//
//  Merchant.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 17/08/16.
//
//

import Foundation

private let mcc_descriptions: [String: String] = [
  "plane_mcc": "transaction_details.basic_info.category.plane_mcc",
  "car_mcc": "transaction_details.basic_info.category.car_mcc",
  "glass_mcc": "transaction_details.basic_info.category.glass_mcc",
  "finance_mcc": "transaction_details.basic_info.category.finance_mcc",
  "food_mcc": "transaction_details.basic_info.category.food_mcc",
  "gas_mcc": "transaction_details.basic_info.category.gas_mcc",
  "bed_mcc": "transaction_details.basic_info.category.bed_mcc",
  "medical_mcc": "transaction_details.basic_info.category.medical_mcc",
  "camera_mcc": "transaction_details.basic_info.category.camera_mcc",
  "card_mcc": "transaction_details.basic_info.category.card_mcc",
  "cart_mcc": "transaction_details.basic_info.category.cart_mcc",
  "road_mcc": "transaction_details.basic_info.category.road_mcc"
]

@objc open class MCC: NSObject, Codable {
  let code: String?
  let name: String
  let icon: MCCIcon

  init(code: String?, name: String, icon: MCCIcon) {
    self.code = code
    self.name = name
    self.icon = icon
  }

  func image() -> UIImage? {
    return icon.image()
  }

  func description() -> String {
    if let value = mcc_descriptions[name] {
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
