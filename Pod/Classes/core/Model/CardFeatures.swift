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
        } else if container.contains(.api) {
            self = .api
        } else if container.contains(.voIP) {
            self = .voIP
        } else {
            self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .api:
            try container.encode(true, forKey: .api)
        case let .ivr(ivr):
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
        case passCode
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
    public let funding: Funding?
    public let passCode: PassCode?
    public let achAccount: ACHAccountFeature?
    public let inAppProvisioning: InAppProvisioning?
    public let p2pTransfer: P2PTransferFeature?
}

public enum FeatureStatus: String, Equatable, Codable {
    case enabled
    case disabled
}

public struct IVR: Codable {
    public let status: FeatureStatus
    public let phone: PhoneNumber
}

public struct Funding: Codable {
    public let status: FeatureStatus
    public let cardNetworks: [CardNetwork]
    public let limits: FundingLimits
    public let softDescriptor: String
}

public struct FundingLimits: Codable {
    public let daily: FundingSingleLimit
}

public struct FundingSingleLimit: Codable {
    public let max: Amount
}

public struct AllowedBalanceType: Codable {
    public let type: String
    public let baseUri: String
}

public struct PassCode: Codable {
    public let status: FeatureStatus
    public let passCodeSet: Bool
    public let verificationRequired: Bool
}

extension JSON {
    var cardFeatures: CardFeatures? {
        let setPin = self["set_pin"].featureAction
        let getPin = self["get_pin"].featureAction
        let allowedBalanceTypes = self["select_balance_store"]["allowed_balance_types"].linkObject as? [AllowedBalanceType]
        let activation = self["activation"].featureAction
        let ivrSupport = self["support"].ivr
        let funding = self["add_funds"].funding
        let passCode = self["passcode"].passCode
        let achAccount = self["ach"].achAccount
        let inAppProvisioning = self["in_app_provisioning"].inAppProvisioning
        let p2pTransfer = self["supports_p2p_transfers"].p2pTransfer
        return CardFeatures(setPin: setPin, getPin: getPin, allowedBalanceTypes: allowedBalanceTypes,
                            activation: activation, ivrSupport: ivrSupport, funding: funding,
                            passCode: passCode, achAccount: achAccount,
                            inAppProvisioning: inAppProvisioning, p2pTransfer: p2pTransfer)
    }

    var funding: Funding? {
        guard let rawStatus = self["status"].string,
              let status = FeatureStatus(rawValue: rawStatus),
              let cardNetworks = self["card_networks"].array?.compactMap({
                  CardNetwork.cardNetworkFrom(description: $0.string)
              }),
              let softDescriptor = self["soft_descriptor"].string,
              let limits = self["limits"].fundingLimits else { return nil }
        return Funding(status: status, cardNetworks: cardNetworks, limits: limits, softDescriptor: softDescriptor)
    }

    var fundingLimits: FundingLimits? {
        guard let daily = self["daily"].fundingSingleLimit else {
            return nil
        }
        return FundingLimits(daily: daily)
    }

    var fundingSingleLimit: FundingSingleLimit? {
        guard let max = self["max"].amount else {
            return nil
        }
        return FundingSingleLimit(max: max)
    }

    var passCode: PassCode? {
        guard let rawStatus = self["status"].string,
              let status = FeatureStatus(rawValue: rawStatus),
              let passCodeSet = self["passcode_set"].bool,
              let verificationRequired = self["verification_required"].bool
        else {
            ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                  reason: "Can't parse PassCode \(self)"))
            return nil
        }

        return PassCode(status: status, passCodeSet: passCodeSet, verificationRequired: verificationRequired)
    }

    var ivr: IVR? {
        guard let rawStatus = self["status"].string,
              let status = FeatureStatus(rawValue: rawStatus),
              let phone = self["ivr_phone"].phone
        else {
            ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                  reason: "Can't parse IVR \(self)"))
            return nil
        }

        return IVR(status: status, phone: phone)
    }

    var allowedBalanceType: AllowedBalanceType? {
        guard let balanceType = self["balance_type"].string,
              let uri = self["base_uri"].string
        else {
            ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                  reason: "Can't parse AllowedBalanceType \(self)"))
            return nil
        }

        return AllowedBalanceType(type: balanceType, baseUri: uri)
    }

    var featureAction: FeatureAction? {
        guard let rawStatus = self["status"].string,
              let status = FeatureStatus(rawValue: rawStatus)
        else {
            ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                  reason: "Can't parse CardActivation \(self)"))
            return nil
        }
        guard status == .enabled else { return nil }

        let type: FeatureSource
        if self["type"].string == "api" {
            type = .api
        } else if self["type"].string == "voip" {
            type = .voIP
        } else {
            guard let ivr = ivr else {
                ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                      reason: "Can't parse CardActivation \(self)"))
                return FeatureAction(source: .unknown, status: status)
            }
            type = .ivr(ivr)
        }
        return FeatureAction(source: type, status: status)
    }

    var achAccount: ACHAccountFeature? {
        guard let rawStatus = self["status"].string,
              let status = FeatureStatus(rawValue: rawStatus)
        else {
            ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                  reason: "Can't parse bank account \(self)"))
            return nil
        }
        let accountDetails = self["account_details"].achAccountDetails
        let isAccountProvisioned = self["account_provisioned"].boolValue
        let disclaimer = self["disclaimer"].disclaimer

        return ACHAccountFeature(status: status,
                                 isAccountProvisioned: isAccountProvisioned,
                                 disclaimer: disclaimer,
                                 achAccountDetails: accountDetails)
    }

    var disclaimer: Disclaimer? {
        guard let agreementKeysJSON = self["agreement_keys"].array,
              let content = self["content"].content
        else {
            ErrorLogger.defaultInstance().log(error:
                ServiceError(code: ServiceError.ErrorCodes.jsonError,
                             reason: "Can't parse bank account disclaimer \(self)")
            )
            return nil
        }
        let agreementKeys = agreementKeysJSON.map { $0.stringValue }
        return Disclaimer(agreementKeys: agreementKeys, content: content)
    }

    var p2pTransfer: P2PTransferFeature? {
        guard let rawStatus = self["status"].string,
              let status = FeatureStatus(rawValue: rawStatus)
        else {
            ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                  reason: "Can't parse in app provisionig \(self)"))
            return nil
        }
        return P2PTransferFeature(status: status)
    }

    var inAppProvisioning: InAppProvisioning? {
        guard let rawStatus = self["status"].string,
              let status = FeatureStatus(rawValue: rawStatus)
        else {
            ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                  reason: "Can't parse in app provisionig \(self)"))
            return nil
        }
        return InAppProvisioning(status: status)
    }
}
