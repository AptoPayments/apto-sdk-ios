//
//  Custodian.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 05/03/2018.
//

import UIKit

public enum CustodianType: String {
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

@objc open class Custodian: NSObject {
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
}
