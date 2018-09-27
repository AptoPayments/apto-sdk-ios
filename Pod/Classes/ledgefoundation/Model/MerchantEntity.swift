//
//  Merchant.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 17/08/16.
//
//

import Foundation

@objc open class MCC: NSObject {
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
}

@objc open class Merchant: NSObject {
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
