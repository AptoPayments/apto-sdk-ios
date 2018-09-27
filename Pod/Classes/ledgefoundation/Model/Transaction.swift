//
//  Transaction.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 20/03/2018.
//

import UIKit

public enum TransactionState {
  case pending
  case authorized
  case disputed
  case other
  static func transactionStateFrom(description:String?) -> TransactionState? {
    guard let description = description else {
      return nil
    }
    if description.uppercased() == "PENDING" {
      return .pending
    }
    else if description.uppercased() == "AUTHORIZED" {
      return .authorized
    }
    else if description.uppercased() == "DISPUTED" {
      return .disputed
    }
    else {
      return .other
    }
  }
  func description() -> String {
    switch self {
    case .pending: return "PENDING"
    case .authorized: return "AUTHORIZED"
    case .disputed: return "DISPUTED"
    case .other: return "Other"
    }
  }
  
}

public enum MCCIcon: String {
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

public enum TransactionType: String {
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
  func description() -> String {
    switch self {
    case .pending: return "Pending"
    case .reversal: return "Reversal"
    case .purchase: return "Purchase"
    case .pin_purchase: return "PIN Purchase"
    case .refund: return "Refund"
    case .decline: return "Decline"
    case .balance_inquiry: return "Balance Inquiry"
    case .withdrawal: return "Withdrawal"
    case .other: return "Unavailable"
    }
  }
}

@objc open class Transaction: NSObject {
  
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
  let state: TransactionState?
  let adjustments: [TransactionAdjustment]?

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
              state: TransactionState?,
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

@objc open class TransactionSettlement: NSObject {
  let createdAt: Date
  let amount: Amount?
  public init(createdAt: Date, amount: Amount?) {
    self.createdAt = createdAt
    self.amount = amount
  }
}

public enum TransactionAdjustmentType: String {
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

@objc open class TransactionAdjustment: NSObject {
  let id: String?
  let externalId: String?
  let createdAt: Date?
  let localAmount: Amount?
  let nativeAmount: Amount?
  let exchangeRate: Double?
  let type: TransactionAdjustmentType
  let fundingSourceName: String?
  public init(id: String?, externalId: String?, createdAt: Date?, localAmount: Amount?, nativeAmount: Amount?, exchangeRate: Double?, type: TransactionAdjustmentType, fundingSourceName: String?) {
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
