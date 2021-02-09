//
//  JSONRouter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 10/02/16.
//
//

import Alamofire

public enum JSONRouter {

  case contextConfig
  case createUser
  case login
  case userInfo
  case updateUserInfo
  case primaryVerificationStart
  case verificationStart
  case verificationFinish
  case verificationStatus
  case verificationRestart
  case financialAccounts
  case financialAccountsDetails
  case financialAccountTransactions
  case financialAccountFundingSource
  case financialAccountMonthlySpending
  case monthlyStatementsPeriod
  case monthlyStatements
  case addBankAccounts
  case bankOauthConfig
  case issueVirtualCard
  case activatePhysicalCard
  case updateFinancialAccountState
  case updateFinancialAccountPIN
  case setCardPassCode
  case financialAccountFundingSources
  case pushDevice
  case documentOCR
  case documentOCRStatus
  case cardProduct
  case cardProducts
  case applyToCard
  case cardApplication
  case cardApplicationStatus
  case setBalanceStore
  case acceptDisclaimer
  case issueCard
  case startOauth
  case oauthStatus
  case notificationPreferences
  case saveOauthUserData
  case fetchOauthUserData
  case voIPAuthorization
  case paymentSources
  case paymentSource
  case paymentSourcesPushFunds
    case bankAccountDetails
    case assignBankAccount
    case recordAgreementAction
    
  var URLString: String {
    switch self {
    case .contextConfig:return "/config"
    case .createUser: return "/user"
    case .login: return "/user/login"
    case .userInfo: return "/user"
    case .updateUserInfo: return "/user"
    case .primaryVerificationStart: return "/verifications/primary/start"
    case .verificationStart: return "/verifications/start"
    case .verificationFinish: return "/verifications/:verificationId/finish"
    case .verificationStatus: return "/verifications/:verificationId/status"
    case .verificationRestart: return "/verifications/:verificationId/restart"
    case .financialAccounts: return "/user/accounts"
    case .financialAccountsDetails: return "/user/accounts/:accountId/details"
    case .financialAccountTransactions: return "/user/accounts/:accountId/transactions"
    case .financialAccountFundingSource: return "/user/accounts/:accountId/balance"
    case .financialAccountMonthlySpending: return "/user/accounts/:accountId/stats/monthly_spending?month=:month&year=:year" // swiftlint:disable:this line_length
    case .monthlyStatementsPeriod: return "/user/statements/period"
    case .monthlyStatements: return "/user/statements"
    case .addBankAccounts: return "/user/accounts"
    case .bankOauthConfig: return "/bankoauth"
    case .issueVirtualCard: return "/user/accounts/issuecard"
    case .activatePhysicalCard: return "/user/accounts/:accountId/activate_physical"
    case .updateFinancialAccountState: return "/user/accounts/:accountId/:action"
    case .updateFinancialAccountPIN: return "/user/accounts/:accountId/pin"
    case .setCardPassCode: return "/user/accounts/:cardId/passcode"
    case .financialAccountFundingSources: return "/user/accounts/:accountId/balances"
    case .pushDevice: return "/user/pushdevice"
    case .documentOCR: return "/documents/ocr"
    case .documentOCRStatus: return "/documents/ocr/:verificationId"
    case .cardProduct: return "/config/cardproducts/:cardProductId"
    case .cardProducts: return "/config/cardproducts"
    case .applyToCard: return "/user/accounts/apply"
    case .cardApplication: return "/user/accounts/applications/:applicationId"
    case .cardApplicationStatus: return "/user/accounts/applications/:applicationId/status"
    case .setBalanceStore: return "/user/accounts/applications/:applicationId/select_balance_store"
    case .acceptDisclaimer: return "/disclaimers/accept"
    case .issueCard: return "/user/accounts/issuecard"
    case .startOauth: return "/oauth"
    case .oauthStatus: return "/oauth/:attemptId"
    case .notificationPreferences: return "/user/notifications/preferences"
    case .saveOauthUserData: return "/oauth/userdata/save"
    case .fetchOauthUserData: return "/oauth/userdata/retrieve"
    case .voIPAuthorization: return "/voip/authorization"
    case .paymentSource: return "/payment_sources/:paymentSourceId"
    case .paymentSources: return "/payment_sources"
    case .paymentSourcesPushFunds: return "/payment_sources/:paymentSourceId/push"
    case .bankAccountDetails: return "/balances/:balance_id/bank-account"
    case .assignBankAccount: return "/balances/:balance_id/bank-account"
    case .recordAgreementAction: return "/agreements"
    }
  }

}

class URLWrapper: URLConvertible {
  let baseUrl: String
  let url: JSONRouter
  let urlParameters: [String: String]?
  let urlTrailing: String?

  init (baseUrl: String, url: JSONRouter, urlTrailing: String? = nil, urlParameters: [String: String]? = nil) {
    self.baseUrl = baseUrl
    self.url = url
    self.urlTrailing = urlTrailing
    self.urlParameters = urlParameters
  }

  public func asURL() throws -> URL {
    var trailing: String = ""
    if let urlTrailing = self.urlTrailing {
      trailing = "/" + urlTrailing
    }

    guard let urlParameters = self.urlParameters else {
      return URL(string: self.baseUrl + self.url.URLString + trailing)! // swiftlint:disable:this force_unwrapping
    }
    let url = self.url.URLString.replace(urlParameters)
    let trailingParameters = urlParameters.urlRepresentation
    // swiftlint:disable:next force_unwrapping
    return URL(string: self.baseUrl + url + trailing + (!trailingParameters.isEmpty ? "?" + trailingParameters : ""))!
  }
}

extension Dictionary {
  var urlRepresentation: String {
    return self.compactMap { key, value -> String? in
      guard let key = key as? String, let value = value as? String, !key.startsWith(":") else {
        return nil
      }
      return key + "=" + value
      }.joined(separator: "&")
  }
}

extension JSONTransportEnvironment: BaseURLProvider {
  public func baseUrl() -> String {
    return baseUrl(self)
  }

  public func baseUrl(_ environment: JSONTransportEnvironment) -> String {
    switch environment {
    case .local:
      return "http://local.ledge.me:5001/v1"
    case .staging:
      return "https://api.stg.aptopayments.com/v1"
    case .sandbox:
      return "https://api.sbx.aptopayments.com/v1"
    case .live:
      return "https://api.aptopayments.com/v1"
    }
  }
}

public protocol PCIVaultURLProvider {
  func pciVaultBaseUrl() -> String
}

extension JSONTransportEnvironment: PCIVaultURLProvider {
  public func pciVaultBaseUrl() -> String {
    return pciVaultBaseUrl(self)
  }

  public func pciVaultBaseUrl(_ environment: JSONTransportEnvironment) -> String {
    switch environment {
    case .local:
      return self.baseUrl()
    case .staging:
      return "https://vault.stg.aptopayments.com/v1"
    case .sandbox:
      return "https://vault.sbx.aptopayments.com/v1"
    case .live:
      return "https://vault.aptopayments.com/v1"
    }
  }
}
