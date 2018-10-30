//
//  CardFeatures.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//

import SwiftyJSON

public struct CardFeatures {
  public let ivr: IVR?
  public let changePin: FeatureStatus
  public let allowedBalanceTypes: [AllowedBalanceType]?
}

public enum FeatureStatus: String, Equatable {
  case enabled
  case disabled
}

public struct IVR {
  public let status: FeatureStatus
  public let phone: PhoneNumber
}

public struct AllowedBalanceType {
  public let type: CustodianType
  public let baseUri: String
}

extension JSON {
  var cardFeatures: CardFeatures? {
    let rawChangePinStatus = self["set_pin"]["status"].string ?? ""
    let changePinStatus = FeatureStatus(rawValue: rawChangePinStatus) ?? .disabled
    let ivr = self["get_pin"].ivr
    let allowedBalanceTypes: [AllowedBalanceType]?
    if let rawAllowedBalanceTypesArray = self["select_balance_store"]["allowed_balance_types"].array {
      allowedBalanceTypes = rawAllowedBalanceTypesArray.compactMap { json -> AllowedBalanceType? in
        return json.allowedBalanceType
      }
    }
    else {
      allowedBalanceTypes = nil
    }

    return CardFeatures(ivr: ivr, changePin: changePinStatus, allowedBalanceTypes: allowedBalanceTypes)
  }

  var ivr: IVR? {
    guard let rawStatus = self["status"].string,
          let status = FeatureStatus(rawValue: rawStatus),
          let phone = self["ivr_phone"].phone else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse IVR \(self)"))
      return nil
    }

    return IVR(status: status, phone: phone)
  }

  var allowedBalanceType: AllowedBalanceType? {
    guard let rawType = self["balance_type"].string, let balanceType = CustodianType(rawValue: rawType),
          let uri = self["base_uri"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse AllowedBalanceType \(self)"))
      return nil
    }

    return AllowedBalanceType(type: balanceType, baseUri: uri)
  }
}
