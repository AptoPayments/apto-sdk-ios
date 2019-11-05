//
//  Transaction.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 20/03/2018.
//

import Foundation

public enum TransactionState: String, Codable, CaseIterable {
  case pending
  case declined
  case complete
  case other

  static func transactionStateFrom(description: String?) -> TransactionState {
    if let description = description, let state = TransactionState(rawValue: description.lowercased()) {
      return state
    }
    else {
      return .other
    }
  }

  public func description() -> String {
    switch self {
    case .pending: return "transaction_details.basic_info.transaction_status.pending".podLocalized()
    case .declined: return "transaction_details.basic_info.transaction_status.declined".podLocalized()
    case .complete: return "transaction_details.basic_info.transaction_status.complete".podLocalized()
    case .other: return "transaction_details.basic_info.transaction_status.other".podLocalized()
    }
  }
}

public enum MCCIcon: String, Codable {
  case plane
  case car
  case glass
  case finance
  case food
  case gas
  case bed
  case medical
  case camera
  case card
  case cart
  case road
  case other

  static func from(iconName: String?) -> MCCIcon {
    if let iconName = iconName, let mccIcon = MCCIcon(rawValue: iconName.lowercased()) {
      return mccIcon
    }
    else {
      return .other
    }
  }

  public var name: String {
    return mccDescriptions[self.rawValue]?.podLocalized()
      ?? "transaction_details.basic_info.category.unavailable".podLocalized()
  }
}

public enum TransactionType: String, Codable {
  case pending
  case reversal
  case purchase
  case pinPurchase = "pin_purchase"
  case refund
  case decline
  case balanceInquiry = "balance_inquiry"
  case withdrawal
  case credit
  case other

  static func from(typeName: String?) -> TransactionType {
    if let typeName = typeName, let type = TransactionType(rawValue: typeName.lowercased()) {
      return type
    }
    else {
      return .other
    }
  }

  public var amountPrefix: String {
    switch self {
    case .reversal, .refund, .credit:
      return "+ "
    default:
      return ""
    }
  }

  public func description() -> String {
    switch self {
    case .pending: return "transaction_details.details.transaction_type.pending".podLocalized()
    case .reversal: return "transaction_details.details.transaction_type.reversal".podLocalized()
    case .purchase: return "transaction_details.details.transaction_type.purchase".podLocalized()
    case .pinPurchase: return "transaction_details.details.transaction_type.pin_purchase".podLocalized()
    case .refund: return "transaction_details.details.transaction_type.refund".podLocalized()
    case .decline: return "transaction_details.details.transaction_type.decline".podLocalized()
    case .balanceInquiry: return "transaction_details.details.transaction_type.balance_inquiry".podLocalized()
    case .withdrawal: return "transaction_details.details.transaction_type.atm_withdrawal".podLocalized()
    case .credit: return "transaction_details.details.transaction_type.credit".podLocalized()
    case .other: return "transaction_details.details.transaction_type.other".podLocalized()
    }
  }
}

public enum TransactionClass: String, Codable {
  case atm
  case authorised
  case preauthorised
  case declined
  case reversed

  public func description() -> String {
    switch self {
    case .atm: return "transaction_details.details.transaction_class.atm_withdrawal".podLocalized()
    case .authorised: return "transaction_details.details.transaction_class.authorised".podLocalized()
    case .preauthorised: return "transaction_details.details.transaction_class.pending".podLocalized()
    case .declined: return "transaction_details.details.transaction_class.declined".podLocalized()
    case .reversed: return "transaction_details.details.transaction_class.reversed".podLocalized()
    }
  }
}

public enum TransactionDeviceType: String, Codable {
  case ecommerce
  case cardPresent
  case international
  case emv
  case other

  public func description() -> String? {
    switch self {
    case .ecommerce: return "transaction_details.details.device_type.ecommerce".podLocalized()
    case .cardPresent: return "transaction_details.details.device_type.pos".podLocalized()
    case .international: return "transaction_details.details.device_type.international".podLocalized()
    case .emv: return "transaction_details.details.device_type.emv".podLocalized()
    case .other: return nil
    }
  }
}

public enum TransactionDeclineCode: String, Codable, Equatable {
  case nsf = "decline_nsf"
  case badPin = "decline_bad_pin"
  case zeroSix = "decline_06"
  case fourtyTwo = "decline_42"
  case sixty = "decline_60"
  case sixtyOne = "decline_61"
  case sixtyFive = "decline_65"
  case seventy = "decline_70"
  case seventyFive = "decline_75"
  case badCvvOrExp = "decline_bad_cvv_or_exp"
  case badCvv = "decline_bad_cvv"
  case preActive = "decline_pre_active"
  case misc = "decline_misc"
  case other

  public var description: String {
    switch self {
    case .other:
      return "transaction_details.details.decline_default".podLocalized()
    default:
      return "transaction_details.details.\(self.rawValue)".podLocalized()
    }
  }

  static func from(string: String?) -> TransactionDeclineCode? {
    guard let string = string else { return nil }
    if let code = TransactionDeclineCode(rawValue: string) {
      return code
    }
    return .other
  }
}

@objc open class Transaction: NSObject, Codable {
  public let transactionId: String
  public let transactionType: TransactionType
  public let createdAt: Date
  public let transactionDescription: String?
  public let lastMessage: String?
  public let declineCode: TransactionDeclineCode?
  public let merchant: Merchant?
  public let store: Store?
  public let localAmount: Amount?
  public let billingAmount: Amount?
  public let holdAmount: Amount?
  public let cashbackAmount: Amount?
  public let feeAmount: Amount?
  public let nativeBalance: Amount?
  public let settlement: TransactionSettlement?
  public let ecommerce: Bool?
  public let international: Bool?
  public let cardPresent: Bool?
  public let emv: Bool?
  public let cardNetwork: CardNetwork?
  public let state: TransactionState
  public let adjustments: [TransactionAdjustment]?
  public let fundingSourceName: String?

  public var transactionClass: TransactionClass {
    if transactionType == .withdrawal {
      return .atm
    }
    if transactionType == .decline {
      return .declined
    }
    if state == .pending {
      return .preauthorised
    }
    if transactionType == .reversal {
      return .reversed
    }
    return .authorised
  }

  public var deviceType: TransactionDeviceType {
    if ecommerce == true {
      return .ecommerce
    }
    else if cardPresent == true {
      return .cardPresent
    }
    else if international == true {
      return .international
    }
    else if emv == true {
      return .emv
    }
    return .other
  }

  public var localAmountRepresentation: String {
    guard let amount = localAmount else {
      return "-"
    }
    return transactionType.amountPrefix + amount.absText
  }

  public init(transactionId: String,
              transactionType: TransactionType,
              createdAt: Date,
              transactionDescription: String?,
              lastMessage: String?,
              declineCode: TransactionDeclineCode?,
              merchant: Merchant?,
              store: Store?,
              localAmount: Amount?,
              billingAmount: Amount?,
              holdAmount: Amount?,
              cashbackAmount: Amount?,
              feeAmount: Amount?,
              nativeBalance: Amount?,
              settlement: TransactionSettlement?,
              ecommerce: Bool?,
              international: Bool?,
              cardPresent: Bool?,
              emv: Bool?,
              cardNetwork: CardNetwork?,
              state: TransactionState,
              adjustments: [TransactionAdjustment]?,
              fundingSourceName: String?) {
    self.transactionId = transactionId
    self.transactionType = transactionType
    self.createdAt = createdAt
    self.transactionDescription = transactionDescription
    self.lastMessage = lastMessage
    self.declineCode = declineCode
    self.merchant = merchant
    self.store = store
    self.localAmount = localAmount
    self.billingAmount = billingAmount
    self.holdAmount = holdAmount
    self.cashbackAmount = cashbackAmount
    self.feeAmount = feeAmount
    self.nativeBalance = nativeBalance
    self.settlement = settlement
    self.ecommerce = ecommerce
    self.international = international
    self.cardPresent = cardPresent
    self.emv = emv
    self.cardNetwork = cardNetwork
    self.state = state
    self.adjustments = adjustments
    self.fundingSourceName = fundingSourceName
  }
}

@objc open class TransactionSettlement: NSObject, Codable {
  let createdAt: Date
  let amount: Amount?

  public init(createdAt: Date, amount: Amount?) {
    self.createdAt = createdAt
    self.amount = amount
  }
}

public enum TransactionAdjustmentType: String, Codable {
  case capture
  case refund
  case hold
  case release
  case other

  static func from(typeName: String?) -> TransactionAdjustmentType {
    if let typeName = typeName, let type = TransactionAdjustmentType(rawValue: typeName.lowercased()) {
      return type
    }
    else {
      return .other
    }
  }

  public func description() -> String {
    switch self {
    case .capture: return "Capture"
    case .refund: return "Refund"
    case .hold: return "Hold"
    case .release: return "Release"
    case .other: return "Other"
    }
  }
}

@objc open class TransactionAdjustment: NSObject, Codable {
  public let id: String?
  public let externalId: String?
  public let createdAt: Date?
  public let localAmount: Amount?
  public let nativeAmount: Amount?
  public let exchangeRate: Double?
  public let type: TransactionAdjustmentType
  public let fundingSourceName: String?
  public let fee: Amount?

  public init(id: String?,
              externalId: String?,
              createdAt: Date?,
              localAmount: Amount?,
              nativeAmount: Amount?,
              exchangeRate: Double?,
              type: TransactionAdjustmentType,
              fundingSourceName: String?,
              fee: Amount?) {
    self.id = id
    self.externalId = externalId
    self.createdAt = createdAt
    self.localAmount = localAmount
    self.nativeAmount = nativeAmount
    self.exchangeRate = exchangeRate
    self.type = type
    self.fundingSourceName = fundingSourceName
    self.fee = fee
  }
}
