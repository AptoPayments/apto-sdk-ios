import Foundation
import SwiftyJSON

public struct PaymentSourceCardRequest {
  public let pan: String
  public let cvv: String
  public let expirationDate: String
  public let lastFour: String
  public let zipCode: String
  
  public init(pan: String, cvv: String, expirationDate: String, zipCode: String) {
    self.pan = pan
    self.cvv = cvv
    self.expirationDate = expirationDate
    self.lastFour = pan.suffixOf(4)!
    self.zipCode = zipCode
  }
}

public struct PaymentSourceBankRequest {
  public let routingNumber: String
  public let accountNumber: String
  
  public init(routingNumber: String, accountNumber: String) {
    self.routingNumber = routingNumber
    self.accountNumber = accountNumber
  }
}

public enum PaymentSourceRequest {
  case card(PaymentSourceCardRequest)
  case bankAccount(PaymentSourceBankRequest)
}

public struct CardPaymentSource {
  public let id: String
  public let description: String?
  public let type: PaymentSourceType
  public let cardType: String?
  public let network: CardNetwork?
  public let lastFour: String
  public let isPreferred: Bool
}

extension CardPaymentSource {
  public var title: String? {
    guard let cardNetwork = network?.description(), let cardType = self.cardType else {
      return nil
    }
    return "\(cardNetwork) \(cardType)"
  }
}

public struct BankAccountPaymentSource {
  public let id: String
  public let description: String?
  public let type: PaymentSourceType
  public let isPreferred: Bool
}

public enum PaymentSource {
  case card(CardPaymentSource)
  case bankAccount(BankAccountPaymentSource)
  
  public var id: String? {
     switch self {
     case .card(let card):
       return card.id
     case .bankAccount(let bankAccount):
       return bankAccount.id
     }
   }
}

// MARK: - JSON

public enum PaymentSourceType: String {
  case card
  case bankAccount
}

extension JSON {
  var paymentSources: [PaymentSource] {
    let paymentSource = self["payment_sources"].arrayValue
    return paymentSource.compactMap { $0.paymentSource() }
  }
  
  func paymentSource(with key: String = "payment_source") -> PaymentSource? {
    guard let paymentSource = self[key].dictionary, let type = paymentSource["type"]?.string, let paymentSourceType = PaymentSourceType(rawValue: type) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse PaymentSource \(self)"))
      return nil
    }
    
    switch paymentSourceType {
    case .card:
      return cardPaymentSource(with: key)
    case .bankAccount:
      return bankAccountPaymentSource
    }
  }
  
  private func cardPaymentSource(with key: String = "payment_source") -> PaymentSource? {
    let paymentSource = self[key]
    guard let id = paymentSource["id"].string, let lastFour = paymentSource["last_four"].string, let isPreferred = paymentSource["is_preferred"].bool else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse PaymentSource \(self)"))
      return nil
    }
    return .card(
      CardPaymentSource(
        id: id,
        description: paymentSource["description"].string,
        type: .card,
        cardType: paymentSource["card_type"].string,
        network: CardNetwork.cardNetworkFrom(description: paymentSource["card_network"].string),
        lastFour: lastFour,
        isPreferred: isPreferred
    ))
  }
  
  private var bankAccountPaymentSource: PaymentSource? {
    let paymentSource = self["payment_source"]
    guard let id = paymentSource["id"].string, let isPreferred = paymentSource["is_preferred"].bool else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse PaymentSource \(self)"))
      return nil
    }
    
    return .bankAccount(
      BankAccountPaymentSource(
        id: id,
        description: paymentSource["description"].string,
        type: .bankAccount,
        isPreferred: isPreferred))
  }
}
