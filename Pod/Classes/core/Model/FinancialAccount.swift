//
//  FinancialAccount.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 17/10/2016.
//
//

import Foundation

public enum FinancialAccountType: String, Codable {
    case bank
    case card
}

public enum FinancialAccountState: String, Codable {
    case unknown
    case created
    case active
    case inactive
    case cancelled

    static func stateFrom(description: String?) -> FinancialAccountState? {
        switch description?.uppercased() {
        case "UNKNOWN":
            return .unknown
        case "CREATED":
            return .created
        case "ACTIVE":
            return .active
        case "INACTIVE":
            return .inactive
        case "CANCELLED":
            return .cancelled
        default:
            return nil
        }
    }

    func description() -> String {
        switch self {
        case .unknown: return "Unknown"
        case .created: return "Created"
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .cancelled: return "Closed"
        }
    }

    func associatedAction() -> String? {
        switch self {
        case .unknown: return nil
        case .created: return "activate"
        case .active: return "enable"
        case .inactive: return "disable"
        case .cancelled: return nil
        }
    }
}

public enum KYCState: String, Codable {
    case resubmitDetails
    case uploadFile
    case underReview
    case passed
    case rejected
    case temporaryError

    static func stateFrom(description: String?) -> KYCState? {
        switch description?.uppercased() {
        case "RESUBMIT_DETAILS":
            return .resubmitDetails
        case "UPLOAD_FILE":
            return .uploadFile
        case "UNDER_REVIEW":
            return .underReview
        case "PASSED":
            return .passed
        case "REJECTED":
            return .rejected
        case "TEMPORARY_ERROR":
            return .temporaryError
        default:
            return nil
        }
    }
}

@objc open class FinancialAccount: DataPoint, Codable {
    public let accountId: String
    public let accountType: FinancialAccountType
    public let state: FinancialAccountState

    public init(accountId: String, type: FinancialAccountType, state: FinancialAccountState, verified: Bool? = false) {
        self.accountId = accountId
        accountType = type
        self.state = state
        super.init(type: .financialAccount, verified: verified)
    }

    open func quickDescription() -> String {
        return ""
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountId = try container.decode(String.self, forKey: .accountId)
        accountType = try container.decode(FinancialAccountType.self, forKey: .accountType)
        state = try container.decode(FinancialAccountState.self, forKey: .state)
        let verified = try container.decode(Bool.self, forKey: .verified)
        super.init(type: .financialAccount, verified: verified)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(accountType, forKey: .accountType)
        try container.encode(state, forKey: .state)
        try container.encode(verified ?? false, forKey: .verified)
    }

    private enum CodingKeys: String, CodingKey {
        case accountId
        case accountType
        case state
        case verified
    }
}

public enum CardIssuer: String, Codable {
    case marqeta
    case shift
    case other

    static func issuerFrom(description: String?) -> CardIssuer {
        switch description?.uppercased() {
        case "MARQETA":
            return .marqeta
        case "SHIFT":
            return .shift
        default:
            return .other
        }
    }

    func description() -> String {
        switch self {
        case .marqeta: return "Marqeta"
        case .shift: return "Shift"
        case .other: return "Other"
        }
    }
}

public enum CardNetwork: String, Codable {
    case visa
    case mastercard
    case amex
    case discover
    case other

    static func cardNetworkFrom(description: String?) -> CardNetwork? {
        guard let description = description else {
            return nil
        }
        switch description.uppercased() {
        case "VISA":
            return .visa
        case "MASTERCARD":
            return .mastercard
        case "AMEX":
            return .amex
        case "DISCOVER":
            return .discover
        default:
            return .other
        }
    }

    public func description() -> String {
        switch self {
        case .visa: return "Visa"
        case .mastercard: return "MasterCard"
        case .amex: return "Amex"
        case .discover: return "Discover"
        case .other: return "Other"
        }
    }
}

public enum OrderedStatus: String, Codable {
    case notApplicable = "not_applicable"
    case available
    case ordered
    case received
}

public enum Format: String, Codable {
    case unknown
    case virtual
    case physical
}

@objc open class Card: FinancialAccount {
    public let cardProductId: String?
    public let cardNetwork: CardNetwork?
    let cardIssuer: CardIssuer?
    let cardBrand: String?
    public let lastFourDigits: String
    public let cardHolder: String?
    let panToken: String?
    let cvvToken: String?
    public let spendableToday: Amount?
    public let nativeSpendableToday: Amount?
    let totalBalance: Amount?
    let nativeTotalBalance: Amount?
    public var fundingSource: FundingSource?
    public let kyc: KYCState?
    public let orderedStatus: OrderedStatus
    public let format: Format
    public let issuedAt: Date?
    public let features: CardFeatures?
    public let cardStyle: CardStyle?
    public let isInWaitList: Bool?
    var details: CardDetails?
    public let metadata: String?

    public init(accountId: String,
                cardProductId: String?,
                cardNetwork: CardNetwork?,
                cardIssuer: CardIssuer?,
                cardBrand: String?,
                state: FinancialAccountState,
                cardHolder: String? = nil,
                lastFourDigits: String,
                spendableToday: Amount?,
                nativeSpendableToday: Amount?,
                totalBalance: Amount?,
                nativeTotalBalance: Amount?,
                kyc: KYCState?,
                orderedStatus: OrderedStatus,
                format: Format,
                issuedAt: Date?,
                features: CardFeatures? = nil,
                panToken: String? = nil,
                cvvToken: String? = nil,
                cardStyle: CardStyle? = nil,
                verified: Bool? = false,
                isInWaitList: Bool? = nil,
                metadata: String? = nil)
    {
        self.cardProductId = cardProductId
        self.cardNetwork = cardNetwork
        self.cardIssuer = cardIssuer
        self.cardHolder = cardHolder
        self.kyc = kyc
        self.spendableToday = spendableToday
        self.nativeSpendableToday = nativeSpendableToday
        self.totalBalance = totalBalance
        self.nativeTotalBalance = nativeTotalBalance
        self.lastFourDigits = lastFourDigits
        self.panToken = panToken
        self.cvvToken = cvvToken
        self.cardBrand = cardBrand
        self.orderedStatus = orderedStatus
        self.format = format
        self.issuedAt = issuedAt
        self.features = features
        self.cardStyle = cardStyle
        self.isInWaitList = isInWaitList
        self.metadata = metadata
        super.init(accountId: accountId, type: .card, state: state, verified: verified)
    }

    override open func quickDescription() -> String {
        if let cardIssuer = cardIssuer, cardIssuer != .other {
            return "\(cardIssuer) (...\(lastFourDigits))"
        } else {
            return "(...\(lastFourDigits))"
        }
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cardProductId = try container.decodeIfPresent(String.self, forKey: .cardProductId)
        cardNetwork = try container.decodeIfPresent(CardNetwork.self, forKey: .cardNetwork)
        cardIssuer = try container.decodeIfPresent(CardIssuer.self, forKey: .cardIssuer)
        cardBrand = try container.decodeIfPresent(String.self, forKey: .cardBrand)
        cardHolder = try container.decodeIfPresent(String.self, forKey: .cardHolder)
        lastFourDigits = try container.decode(String.self, forKey: .lastFourDigits)
        spendableToday = try container.decodeIfPresent(Amount.self, forKey: .spendableToday)
        nativeSpendableToday = try container.decodeIfPresent(Amount.self, forKey: .nativeSpendableToday)
        totalBalance = try container.decodeIfPresent(Amount.self, forKey: .totalBalance)
        nativeTotalBalance = try container.decodeIfPresent(Amount.self, forKey: .nativeTotalBalance)
        kyc = try container.decodeIfPresent(KYCState.self, forKey: .kyc)
        orderedStatus = try container.decode(OrderedStatus.self, forKey: .orderedStatus)
        format = try container.decode(Format.self, forKey: .format)
        issuedAt = try container.decode(Date.self, forKey: .issuedAt)
        features = try container.decodeIfPresent(CardFeatures.self, forKey: .features)
        panToken = try container.decodeIfPresent(String.self, forKey: .panToken)
        cvvToken = try container.decodeIfPresent(String.self, forKey: .cvvToken)
        cardStyle = try container.decodeIfPresent(CardStyle.self, forKey: .cardStyle)
        fundingSource = try container.decodeIfPresent(FundingSource.self, forKey: .fundingSource)
        isInWaitList = try container.decodeIfPresent(Bool.self, forKey: .isInWaitList)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cardProductId, forKey: .cardProductId)
        try container.encode(cardNetwork, forKey: .cardNetwork)
        try container.encode(cardIssuer, forKey: .cardIssuer)
        try container.encode(cardBrand, forKey: .cardBrand)
        try container.encode(cardHolder, forKey: .cardHolder)
        try container.encode(lastFourDigits, forKey: .lastFourDigits)
        try container.encode(spendableToday, forKey: .spendableToday)
        try container.encode(nativeSpendableToday, forKey: .nativeSpendableToday)
        try container.encode(totalBalance, forKey: .totalBalance)
        try container.encode(nativeTotalBalance, forKey: .nativeTotalBalance)
        try container.encode(kyc, forKey: .kyc)
        try container.encode(orderedStatus, forKey: .orderedStatus)
        try container.encode(format, forKey: .format)
        try container.encode(issuedAt, forKey: .issuedAt)
        try container.encode(features, forKey: .features)
        try container.encode(panToken, forKey: .panToken)
        try container.encode(cvvToken, forKey: .cvvToken)
        try container.encode(cardStyle, forKey: .cardStyle)
        try container.encode(fundingSource, forKey: .fundingSource)
        try container.encode(isInWaitList, forKey: .isInWaitList)
        try container.encode(metadata, forKey: .metadata)
    }

    private enum CodingKeys: String, CodingKey {
        case cardProductId
        case cardNetwork
        case cardIssuer
        case cardHolder
        case kyc
        case spendableToday
        case nativeSpendableToday
        case totalBalance
        case nativeTotalBalance
        case lastFourDigits
        case panToken
        case cvvToken
        case cardBrand
        case orderedStatus
        case format
        case issuedAt
        case features
        case cardStyle
        case fundingSource
        case isInWaitList
        case metadata
    }
}

public enum FundingSourceType: String, Codable {
    case custodianWallet
}

public enum FundingSourceState: String, Codable {
    case valid
    case invalid
}

@objc open class FundingSource: NSObject, Codable {
    public let fundingSourceId: String
    public let fundingSourceType: FundingSourceType
    public let balance: Amount?
    public let amountHold: Amount?
    public let state: FundingSourceState

    public init(fundingSourceId: String,
                type: FundingSourceType,
                balance: Amount?,
                amountHold: Amount?,
                state: FundingSourceState)
    {
        self.fundingSourceId = fundingSourceId
        fundingSourceType = type
        self.balance = balance
        self.amountHold = amountHold
        self.state = state
        super.init()
    }

    public func quickDescription() -> String {
        return ""
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fundingSourceId = try container.decode(String.self, forKey: .fundingSourceId)
        fundingSourceType = try container.decode(FundingSourceType.self, forKey: .fundingSourceType)
        balance = try container.decodeIfPresent(Amount.self, forKey: .balance)
        amountHold = try container.decodeIfPresent(Amount.self, forKey: .amountHold)
        state = try container.decode(FundingSourceState.self, forKey: .state)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fundingSourceId, forKey: .fundingSourceId)
        try container.encode(fundingSourceType, forKey: .fundingSourceType)
        try container.encode(balance, forKey: .balance)
        try container.encode(amountHold, forKey: .amountHold)
        try container.encode(state, forKey: .state)
    }

    private enum CodingKeys: String, CodingKey {
        case fundingSourceId
        case fundingSourceType
        case balance
        case amountHold
        case state
    }
}

public func == (lhs: FundingSource, rhs: FundingSource) -> Bool { // swiftlint:disable:this operator_whitespace
    return lhs.fundingSourceId == rhs.fundingSourceId
}

@objc open class CustodianWallet: FundingSource {
    public let nativeBalance: Amount
    public let custodian: Custodian

    public init(fundingSourceId: String,
                nativeBalance: Amount,
                usdBalance: Amount?,
                usdAmountSpendable _: Amount?,
                usdAmountHold: Amount?,
                state: FundingSourceState,
                custodian: Custodian)
    {
        self.nativeBalance = nativeBalance
        self.custodian = custodian
        super.init(fundingSourceId: fundingSourceId,
                   type: .custodianWallet,
                   balance: usdBalance,
                   amountHold: usdAmountHold,
                   state: state)
    }

    override public func quickDescription() -> String {
        if let name = custodian.name, let usdBalance = balance?.amount.value {
            // swiftlint:disable:next force_unwrapping
            return "\(name) ($\(usdBalance), \(nativeBalance.amount.value!) \(nativeBalance.currency.value!))"
        } else if let name = custodian.name {
            return name
        }
        return ""
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nativeBalance = try container.decode(Amount.self, forKey: .nativeBalance)
        custodian = try container.decode(Custodian.self, forKey: .custodian)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nativeBalance, forKey: .nativeBalance)
        try container.encode(custodian, forKey: .custodian)
    }

    private enum CodingKeys: String, CodingKey {
        case nativeBalance
        case custodian
    }
}
