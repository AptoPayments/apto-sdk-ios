//
//  CardFeatures.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//

import SwiftyJSON

public enum CardActivationType {
  case ivr(_ ivr: IVR)
  case api
}

extension CardActivationType: Codable {
  // MARK: - Codable
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if container.contains(.ivr) {
      let ivr = try container.decode(IVR.self, forKey: .ivr)
      self = .ivr(ivr)
    }
    else {
      self = .api
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .api:
      break
    case .ivr(let ivr):
      try container.encode(ivr, forKey: .ivr)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case ivr
  }
}

public struct CardActivation: Codable {
  public let type: CardActivationType
  public let status: FeatureStatus
}

public struct CardFeatures: Codable {
  public let ivr: IVR?
  public let changePin: FeatureStatus
  public let allowedBalanceTypes: [AllowedBalanceType]?
  public let activation: CardActivation?
}

public enum FeatureStatus: String, Equatable, Codable {
  case enabled
  case disabled
}

public struct IVR: Codable {
  public let status: FeatureStatus
  public let phone: PhoneNumber
}

public struct AllowedBalanceType: Codable {
  public let type: CustodianType
  public let baseUri: String
}

extension JSON {
  var cardFeatures: CardFeatures? {
    let rawChangePinStatus = self["set_pin"]["status"].string ?? ""
    let changePinStatus = FeatureStatus(rawValue: rawChangePinStatus) ?? .disabled
    let ivr = self["get_pin"].ivr
    let allowedBalanceTypes = self["select_balance_store"]["allowed_balance_types"].linkObject as? [AllowedBalanceType]
    let activation = self["activation"].cardActivation

    return CardFeatures(ivr: ivr,
                        changePin: changePinStatus,
                        allowedBalanceTypes: allowedBalanceTypes,
                        activation: activation)
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

  var cardActivation: CardActivation? {
    guard let rawStatus = self["status"].string,
          let status = FeatureStatus(rawValue: rawStatus) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse CardActivation \(self)"))
      return nil
    }
    guard status == .enabled else { return nil }

    let type: CardActivationType
    if self["type"].string == "api" {
      type = .api
    }
    else {
      guard let ivr = self.ivr else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse CardActivation \(self)"))
        return nil
      }
      type = .ivr(ivr)
    }
    return CardActivation(type: type, status: status)
  }
}
