//
//  Transaction.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 20/03/2018.
//

import Foundation

public enum TransactionState: String, Codable {
  case pending
  case authorized
  case disputed
  case other

  static func transactionStateFrom(description: String?) -> TransactionState {
    if let description = description, let state = TransactionState(rawValue: description.lowercased()) {
      return state
    }
    else {
      return .other
    }
  }

  func description() -> String {
    switch self {
    case .pending: return "transaction_details.basic_info.transaction_status.pending".podLocalized()
    case .authorized: return "transaction_details.basic_info.transaction_status.authorized".podLocalized()
    case .disputed: return "transaction_details.basic_info.transaction_status.disputed".podLocalized()
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

  func image() -> UIImage? {
    switch (self) {
    case .plane:
      return UIImage.imageFromPodBundle("mcc_flights")
    case .car:
      return UIImage.imageFromPodBundle("mcc_car")
    case .glass:
      return UIImage.imageFromPodBundle("mcc_alcohol")
    case .finance:
      return UIImage.imageFromPodBundle("mcc_withdraw")
    case .food:
      return UIImage.imageFromPodBundle("mcc_food")
    case .gas:
      return UIImage.imageFromPodBundle("mcc_fuel")
    case .bed:
      return UIImage.imageFromPodBundle("mcc_hotel")
    case .medical:
      return UIImage.imageFromPodBundle("mcc_medicine")
    case .camera:
      return UIImage.imageFromPodBundle("mcc_other")
    case .card:
      return UIImage.imageFromPodBundle("mcc_bank_card")
    case .cart:
      return UIImage.imageFromPodBundle("mcc_purchases")
    case .road:
      return UIImage.imageFromPodBundle("mcc_toll_road")
    case .other:
      return UIImage.imageFromPodBundle("mcc_other")
    }
  }
}

public enum TransactionType: String, Codable {
  case pending
  case reversal
  case purchase
  case pin_purchase
  case refund
  case decline
  case balance_inquiry
  case withdrawal
  case other

  static func from(typeName: String?) -> TransactionType {
    if let typeName = typeName, let type = TransactionType(rawValue: typeName.lowercased()) {
      return type
    }
    else {
      return .other
    }
  }

  func description() -> String? {
    switch self {
    case .pending: return "Pending"
    case .reversal: return "Reversal"
    case .purchase: return "Purchase"
    case .pin_purchase: return "PIN Purchase"
    case .refund: return "Refund"
    case .decline: return "Decline"
    case .balance_inquiry: return "Balance Inquiry"
    case .withdrawal: return "Withdrawal"
    case .other: return nil
    }
  }
}

public enum TransactionClass: String, Codable {
  case atm
  case authorised
  case preauthorised
  case declined
  case reversed

  func description() -> String {
    switch self {
    case .atm: return "transaction_details.details.transaction_type.atm_withdrawal".podLocalized()
    case .authorised: return "transaction_details.details.transaction_type.authorised".podLocalized()
    case .preauthorised: return "transaction_details.details.transaction_type.pending".podLocalized()
    case .declined: return "transaction_details.details.transaction_type.declined".podLocalized()
    case .reversed: return "transaction_details.details.transaction_type.reversed".podLocalized()
    }
  }
}

public enum TransactionDeviceType: String, Codable {
  case ecommerce
  case cardPresent
  case international
  case emv
  case other

  func description() -> String? {
    switch self {
    case .ecommerce: return "transaction_details.details.device_type.ecommerce".podLocalized()
    case .cardPresent: return "transaction_details.details.device_type.pos".podLocalized()
    case .international: return "transaction_details.details.device_type.international".podLocalized()
    case .emv: return "transaction_details.details.device_type.emv".podLocalized()
    case .other: return nil
    }
  }
}

@objc open class Transaction: NSObject, Codable {
  let transactionId: String
  let transactionType: TransactionType
  let createdAt: Date
  let externalTransactionId: String?
  let transactionDescription: String?
  let lastMessage: String?
  let declineReason: String?
  let merchant: Merchant?
  let store: Store?
  let localAmount: Amount?
  let billingAmount: Amount?
  let holdAmount: Amount?
  let cashbackAmount: Amount?
  let feeAmount: Amount?
  let nativeBalance: Amount?
  let settlement: TransactionSettlement?
  let ecommerce: Bool?
  let international: Bool?
  let cardPresent: Bool?
  let emv: Bool?
  let cardNetwork: CardNetwork?
  let state: TransactionState
  let adjustments: [TransactionAdjustment]?
  var transactionClass: TransactionClass {
    get {
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
  }
  var deviceType: TransactionDeviceType {
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

  public init(transactionId: String,
              transactionType: TransactionType,
              createdAt: Date,
              externalTransactionId: String?,
              transactionDescription: String?,
              lastMessage: String?,
              declineReason: String?,
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
              adjustments: [TransactionAdjustment]?) {
    self.transactionId = transactionId
    self.transactionType = transactionType
    self.createdAt = createdAt
    self.externalTransactionId = externalTransactionId
    self.transactionDescription = transactionDescription
    self.lastMessage = lastMessage
    self.declineReason = declineReason
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

  func description() -> String {
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
  let id: String?
  let externalId: String?
  let createdAt: Date?
  let localAmount: Amount?
  let nativeAmount: Amount?
  let exchangeRate: Double?
  let type: TransactionAdjustmentType
  let fundingSourceName: String?

  public init(id: String?,
              externalId: String?,
              createdAt: Date?,
              localAmount: Amount?,
              nativeAmount: Amount?,
              exchangeRate: Double?,
              type: TransactionAdjustmentType,
              fundingSourceName: String?) {
    self.id = id
    self.externalId = externalId
    self.createdAt = createdAt
    self.localAmount = localAmount
    self.nativeAmount = nativeAmount
    self.exchangeRate = exchangeRate
    self.type = type
    self.fundingSourceName = fundingSourceName
  }
}
