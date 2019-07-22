//
//  CardFeatures.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//

import SwiftyJSON

public enum FeatureSource {
  case ivr(_ ivr: IVR)
  case api
  case voIP
  case unknown
}

extension FeatureSource: Codable {
  // MARK: - Codable
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if container.contains(.ivr) {
      let ivr = try container.decode(IVR.self, forKey: .ivr)
      self = .ivr(ivr)
    }
    else if container.contains(.api) {
      self = .api
    }
    else if container.contains(.voIP) {
      self = .voIP
    }
    else {
      self = .unknown
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .api:
      try container.encode(true, forKey: .api)
    case .ivr(let ivr):
      try container.encode(ivr, forKey: .ivr)
    case .voIP:
      try container.encode(true, forKey: .voIP)
    case .unknown:
      break
    }
  }

  private enum CodingKeys: String, CodingKey {
    case ivr
    case api
    case voIP
  }
}

public struct FeatureAction: Codable {
  public let source: FeatureSource
  public let status: FeatureStatus
}

public struct CardFeatures: Codable {
  public let setPin: FeatureAction?
  public let getPin: FeatureAction?
  public let allowedBalanceTypes: [AllowedBalanceType]?
  public let activation: FeatureAction?
  public let ivrSupport: IVR?
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
    let setPin = self["set_pin"].featureAction
    let getPin = self["get_pin"].featureAction
    let allowedBalanceTypes = self["select_balance_store"]["allowed_balance_types"].linkObject as? [AllowedBalanceType]
    let activation = self["activation"].featureAction
    let ivrSupport = self["support"].ivr

    return CardFeatures(setPin: setPin, getPin: getPin,  allowedBalanceTypes: allowedBalanceTypes,
                        activation: activation, ivrSupport: ivrSupport)
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

  var featureAction: FeatureAction? {
    guard let rawStatus = self["status"].string,
          let status = FeatureStatus(rawValue: rawStatus) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse CardActivation \(self)"))
      return nil
    }
    guard status == .enabled else { return nil }

    let type: FeatureSource
    if self["type"].string == "api" {
      type = .api
    }
    else if self["type"].string == "voip" {
      type = .voIP
    }
    else {
      guard let ivr = self.ivr else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse CardActivation \(self)"))
        return FeatureAction(source: .unknown, status: status)
      }
      type = .ivr(ivr)
    }
    return FeatureAction(source: type, status: status)
  }
}
