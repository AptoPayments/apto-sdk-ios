//
//  FinancialAccount.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 17/10/2016.
//
//

import Foundation

public enum FinancialAccountType {
  case bank
  case card
}

public enum FinancialAccountState {
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

public enum KYCState {
  case resubmitDetails()
  case uploadFile()
  case underReview()
  case passed
  case rejected()
  case temporaryError()

  static func stateFrom(description: String?) -> KYCState? {
    switch description?.uppercased() {
    case "RESUBMIT_DETAILS":
      return .resubmitDetails()
    case "UPLOAD_FILE":
      return .uploadFile()
    case "UNDER_REVIEW":
      return .underReview()
    case "PASSED":
      return .passed
    case "REJECTED":
      return .rejected()
    case "TEMPORARY_ERROR":
      return .temporaryError()
    default:
      return nil
    }
  }

}

@objc open class FinancialAccount: DataPoint {
  public let accountId: String
  public let accountType: FinancialAccountType
  public let state: FinancialAccountState

  public init(accountId: String, type: FinancialAccountType, state: FinancialAccountState, verified: Bool? = false) {
    self.accountId = accountId
    self.accountType = type
    self.state = state
    super.init(type: .financialAccount, verified: verified)
  }

  open func quickDescription() -> String {
    return ""
  }
}

@objc open class BankAccount: FinancialAccount {
  let bankName: String
  let lastFourDigits: String

  public init(accountId: String,
              bankName: String,
              lastFourDigits: String,
              state: FinancialAccountState,
              verified: Bool? = false) {
    self.bankName = bankName
    self.lastFourDigits = lastFourDigits
    super.init(accountId: accountId, type: .bank, state: state, verified: verified)
  }

  override open func quickDescription() -> String {
    return "\(bankName) (...\(lastFourDigits))"
  }
}

public enum CardIssuer {
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

public enum CardNetwork {
  case visa
  case mastercard
  case amex
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
    default:
      return .other
    }
  }

  func description() -> String {
    switch self {
    case .visa: return "Visa"
    case .mastercard: return "MasterCard"
    case .amex: return "Amex"
    case .other: return "Other"
    }
  }
}

@objc open class Card: FinancialAccount {
  let cardNetwork: CardNetwork?
  let cardIssuer: CardIssuer?
  let cardBrand: String?
  let lastFourDigits: String
  var cardHolder: String?
  var pan: String?
  var cvv: String?
  let panToken: String?
  let cvvToken: String?
  let expiration: String?
  let spendableToday: Amount?
  let nativeSpendableToday: Amount?
  var fundingSource: FundingSource?
  let kyc: KYCState?
  let physicalCardActivationRequired: Bool?
  let features: CardFeatures?
  let cardStyle: CardStyle?

  public init(accountId: String,
              cardNetwork: CardNetwork?,
              cardIssuer: CardIssuer?,
              cardBrand: String?,
              state: FinancialAccountState,
              cardHolder: String? = nil,
              pan: String? = nil,
              cvv: String? = nil,
              lastFourDigits: String,
              expiration: String?,
              spendableToday: Amount?,
              nativeSpendableToday: Amount?,
              kyc: KYCState?,
              physicalCardActivationRequired: Bool?,
              features: CardFeatures? = nil,
              panToken: String? = nil,
              cvvToken: String? = nil,
              cardStyle: CardStyle? = nil,
              verified: Bool? = false) {
    self.cardNetwork = cardNetwork
    self.cardIssuer = cardIssuer
    self.cardHolder = cardHolder
    self.pan = pan
    self.cvv = cvv
    self.kyc = kyc
    self.spendableToday = spendableToday
    self.nativeSpendableToday = nativeSpendableToday
    self.lastFourDigits = lastFourDigits
    self.expiration = expiration
    self.panToken = panToken
    self.cvvToken = cvvToken
    self.cardBrand = cardBrand
    self.physicalCardActivationRequired = physicalCardActivationRequired
    self.features = features
    self.cardStyle = cardStyle
    super.init(accountId: accountId, type: .card, state: state, verified: verified)
  }

  override open func quickDescription() -> String {
    if let cardIssuer = self.cardIssuer, cardIssuer != .other {
      return "\(cardIssuer) (...\(lastFourDigits))"
    }
    else {
      return "(...\(lastFourDigits))"
    }
  }
}

public enum FundingSourceType: String {
  case custodianWallet
}

public enum FundingSourceState: String {
  case valid
  case invalid
}

@objc open class FundingSource: NSObject {
  public let fundingSourceId: String
  public let fundingSourceType: FundingSourceType
  public let balance: Amount?
  public let amountHold: Amount?
  public let state: FundingSourceState

  public init(fundingSourceId: String,
              type: FundingSourceType,
              balance: Amount?,
              amountHold: Amount?,
              state: FundingSourceState) {
    self.fundingSourceId = fundingSourceId
    self.fundingSourceType = type
    self.balance = balance
    self.amountHold = amountHold
    self.state = state
    super.init()
  }

  public func quickDescription() -> String {
    return ""
  }

  public static func ==(lhs: FundingSource, rhs: FundingSource) -> Bool { // swiftlint:disable:this operator_whitespace
    return lhs.fundingSourceId == rhs.fundingSourceId
  }
}

@objc open class CustodianWallet: FundingSource {
  let nativeBalance: Amount
  let custodian: Custodian

  public init(fundingSourceId: String,
              nativeBalance: Amount,
              usdBalance: Amount?,
              usdAmountSpendable: Amount?,
              usdAmountHold: Amount?,
              state: FundingSourceState,
              custodian: Custodian) {
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
    }
    else if let name = custodian.name {
      return name
    }
    return ""
  }
}

public enum BalanceVersion: String {
  case v1
  case v2
}
