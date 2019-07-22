//
//  Store.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 15/08/16.
//
//

import Foundation

@objc open class Store: NSObject, Codable {
  public let id: String?
  public var storeKey: String?
  public let name: String?
  public let latitude: Double?
  public let longitude: Double?
  public let address: Address?
  public let merchant: Merchant?

  public init(id: String?,
              storeKey: String?,
              name: String?,
              latitude: Double?,
              longitude: Double?,
              address: Address?,
              merchant: Merchant?) {
    self.id = id
    self.storeKey = storeKey
    self.name = name
    self.address = address
    self.merchant = merchant
    self.latitude = latitude
    self.longitude = longitude
  }
}
