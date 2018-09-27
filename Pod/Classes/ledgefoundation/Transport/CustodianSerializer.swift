//
//  CustodianSerializer.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 05/03/2018.
//

import UIKit

extension Custodian {

  public func jsonSerialize() -> [String: AnyObject] {
    var data: [String: AnyObject] = [:]
    data["custodian_type"] = "custodian" as AnyObject
    switch (self.custodianType) {
    case .coinbase:
      data["custodian_type"] = "coinbase" as AnyObject
      if let externalCredentials = self.externalCredentials {
        data["credential"] = externalCredentials.jsonSerialize() as AnyObject
      }
    }
    return data
  }

  public func jsonSerializeForAddFundingSource() -> [String: AnyObject] {
    var data: [String: AnyObject] = [:]
    data["custodian_type"] = "custodian" as AnyObject
    switch (self.custodianType) {
    case .coinbase:
      data["custodian_type"] = "coinbase" as AnyObject
      if let externalCredentials = self.externalCredentials {
        data += externalCredentials.jsonSerializeForAddFundingSource()
      }
    }
    return data
  }

}
