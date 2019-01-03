//
//  Custodian.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 05/03/2018.
//

import UIKit

public enum CustodianType: String, Codable {
  case coinbase

  func name() -> String {
    switch self {
    case .coinbase:
      return "Coinbase"
    }
  }

  func logo() -> UIImage? {
    switch self {
    case .coinbase:
      return UIImage.imageFromPodBundle("coinbase_logo.png")
    }
  }
}

@objc open class Custodian: NSObject, Codable {
  public let custodianType: CustodianType
  public let name: String?
  open var externalCredentials: ExternalCredential?

  public init(custodianType: CustodianType, name: String?) {
    self.custodianType = custodianType
    self.name = name
    super.init()
  }

  public func custodianName() -> String {
    if let name = self.name {
      return name
    }
    return custodianType.name()
  }

  public func custodianLogo() -> UIImage? {
    return custodianType.logo()
  }

  // MARK: - Codable
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.custodianType = try container.decode(CustodianType.self, forKey: .custodianType)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.externalCredentials = try container.decodeIfPresent(ExternalCredential.self, forKey: .externalCredentials)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(custodianType, forKey: .custodianType)
    if let name = self.name {
      try container.encode(name, forKey: .name)
    }
    if let externalCredentials = self.externalCredentials {
      try container.encode(externalCredentials, forKey: .externalCredentials)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case custodianType
    case name
    case externalCredentials
  }
}
