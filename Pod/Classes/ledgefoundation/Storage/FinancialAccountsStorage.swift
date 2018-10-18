//
//  FinancialAccountsStorage.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 19/10/2016.
//
//

import Foundation

protocol FinancialAccountsStorageProtocol {
  func get(financialAccountsOfType accountType: FinancialAccountType,
           apiKey: String,
           userToken: String,
           callback: @escaping Result<[FinancialAccount], NSError>.Callback)

  func getFinancialAccounts(_ apiKey: String,
                            userToken: String,
                            callback: @escaping Result<[FinancialAccount], NSError>.Callback)
  func getFinancialAccount(_ apiKey: String,
                           userToken: String,
                           accountId: String,
                           retrieveBalance: Bool,
                           callback: @escaping Result<FinancialAccount, NSError>.Callback)
  func getFinancialAccountTransactions(_ apiKey: String,
                                       userToken: String,
                                       accountId: String,
                                       page: Int?,
                                       rows: Int?,
                                       lastTransactionId: String?,
                                       callback: @escaping Result<[Transaction], NSError>.Callback)
  func getFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        callback: @escaping Result<FundingSource?, NSError>.Callback)
  func setFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        fundingSourceId: String,
                                        callback: @escaping Result<FundingSource, NSError>.Callback)
  func addBankAccounts(userToken: String,
                       apiKey: String,
                       publicToken: String,
                       callback: @escaping Result<[BankAccount], NSError>.Callback)
  func addCard(_ apiKey: String,
               userToken: String,
               cardNumber: String,
               cardNetwork: CardNetwork,
               expirationYear: UInt,
               expirationMonth: UInt,
               cvv: String,
               callback: @escaping Result<Card, NSError>.Callback)
  func issueCard(_ apiKey: String,
                 userToken: String,
                 issuer: CardIssuer,
                 custodian: Custodian?,
                 callback: @escaping Result<Card, NSError>.Callback)
  func updateFinancialAccountState(_ apiKey: String,
                                   userToken: String,
                                   accountId: String,
                                   state: FinancialAccountState,
                                   callback: @escaping Result<FinancialAccount, NSError>.Callback)
  func updateFinancialAccountPIN(_ apiKey: String,
                                 userToken: String,
                                 accountId: String,
                                 pin: String,
                                 callback: @escaping Result<FinancialAccount, NSError>.Callback)
  func financialAccountFundingSources(_ apiKey: String,
                                      userToken: String,
                                      accountId: String,
                                      page: Int?,
                                      rows: Int?,
                                      callback: @escaping Result<[FundingSource], NSError>.Callback)
  func addFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        custodian: Custodian,
                                        callback: @escaping Result<FundingSource, NSError>.Callback)
}

extension FinancialAccountsStorageProtocol {
  func getFinancialAccount(_ apiKey: String,
                           userToken: String,
                           accountId: String,
                           retrieveBalance: Bool = true,
                           callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    getFinancialAccount(apiKey,
                        userToken: userToken,
                        accountId: accountId,
                        retrieveBalance: retrieveBalance,
                        callback: callback)
  }
}

class FinancialAccountsStorage: FinancialAccountsStorageProtocol {
  private let transport: JSONTransport

  init(transport: JSONTransport) {
    self.transport = transport
  }

  func get(financialAccountsOfType accountType: FinancialAccountType,
           apiKey: String,
           userToken: String,
           callback: @escaping Result<[FinancialAccount], NSError>.Callback) {
    getFinancialAccounts(apiKey, userToken: userToken) { result in
      callback(result.flatMap { financialAccounts -> Result<[FinancialAccount], NSError> in
        return .success(financialAccounts.filter { $0.accountType == accountType })
      })
    }
  }

  func getFinancialAccounts(_ apiKey: String,
                            userToken: String,
                            callback: @escaping Result<[FinancialAccount], NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.pciVaultBaseUrl(), url: JSONRouter.financialAccounts)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<[FinancialAccount], NSError> in
        guard let financialAccounts = json.linkObject as? [Any] else {
          return .failure(ServiceError(code: .jsonError))
        }
        let parsedFinancialAccounts = financialAccounts.compactMap { obj -> FinancialAccount? in
          return obj as? FinancialAccount
        }
        return .success(parsedFinancialAccounts)
      })
    }
  }

  func getFinancialAccount(_ apiKey: String,
                           userToken: String,
                           accountId: String,
                           retrieveBalance: Bool = true,
                           callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.pciVaultBaseUrl(),
                         url: JSONRouter.financialAccounts,
                         urlTrailing: accountId)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let json):
        guard let financialAccount = json.linkObject as? FinancialAccount else {
          callback(.failure(ServiceError(code: .jsonError)))
          return
        }
        if retrieveBalance == true, let card = financialAccount as? Card, card.cardIssuer == .shift {
          self.getFinancialAccountFundingSource(apiKey,
                                                userToken: userToken,
                                                accountId: accountId) { result in
            callback(result.flatMap { fundingSource -> Result<FinancialAccount, NSError> in
              card.fundingSource = fundingSource
              return .success(card)
            })
          }
        }
        else {
          callback(.success(financialAccount))
        }
      }
    }
  }

  func getFinancialAccountTransactions(_ apiKey: String,
                                       userToken: String,
                                       accountId: String,
                                       page: Int?,
                                       rows: Int?,
                                       lastTransactionId: String?,
                                       callback: @escaping Result<[Transaction], NSError>.Callback) {
    var urlParameters: [String: String] = [
      ":accountId": accountId
    ]
    if let page = page {
      urlParameters["page"] = "\(page)"
    }
    if let rows = rows {
      urlParameters["rows"] = "\(rows)"
    }
    if let lastTransactionId = lastTransactionId {
      urlParameters["last_transaction_id"] = lastTransactionId
    }
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.financialAccountTransactions,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<[Transaction], NSError> in
        guard let transactions = json.linkObject as? [Transaction] else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(transactions)
      })
    }
  }

  func getFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        callback: @escaping Result<FundingSource?, NSError>.Callback) {
    let urlParameters: [String: String] = [
      ":accountId": accountId
    ]
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.financialAccountFundingSource,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      switch result {
      case .failure(let error):
        if error.code == BackendError.ErrorCodes.primaryFundingSourceNotFound.rawValue {
          callback(.success(nil))
        }
        else {
          callback(.failure(error))
        }
      case .success(let json):
        guard let fundingSource = json.linkObject as? FundingSource else {
          callback(.failure(ServiceError(code: .jsonError)))
          return
        }
        callback(.success(fundingSource))
      }
    }
  }

  func setFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        fundingSourceId: String,
                                        callback: @escaping Result<FundingSource, NSError>.Callback) {
    let urlParameters: [String: String] = [
      ":accountId": accountId
    ]
    let data: [String: AnyObject] = [
      "funding_source_id": fundingSourceId as AnyObject
    ]
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.financialAccountFundingSource,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<FundingSource, NSError> in
        guard let fundingSource = json.linkObject as? FundingSource else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(fundingSource)
      })
    }
  }

  func addBankAccounts(userToken: String,
                       apiKey: String,
                       publicToken: String,
                       callback: @escaping Result<[BankAccount], NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.addBankAccounts)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    var data = [String: AnyObject]()
    data["public_token"] = publicToken as AnyObject
    data["type"] = "bank_account" as AnyObject
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<[BankAccount], NSError> in
        guard let bankAccounts = json.linkObject as? [Any] else {
          return .failure(ServiceError(code: .jsonError))
        }
        let parsedBankAccounts = bankAccounts.compactMap { obj -> BankAccount? in
          return obj as? BankAccount
        }
        return .success(parsedBankAccounts)
      })
    }
  }

  func addCard(_ apiKey: String,
               userToken: String,
               cardNumber: String,
               cardNetwork: CardNetwork,
               expirationYear: UInt,
               expirationMonth: UInt,
               cvv: String,
               callback: @escaping Result<Card, NSError>.Callback) {
    guard let lastFourDigits = cardNumber.suffixOf(4) else {
      callback(.failure(ServiceError(code: .internalIncosistencyError)))
      return
    }

    let url = URLWrapper(baseUrl: self.transport.environment.pciVaultBaseUrl(), url: JSONRouter.addCard)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    let expiration = "\(expirationYear)-\(expirationMonth)"
    let card = Card(accountId: "",
                    cardNetwork: cardNetwork,
                    cardIssuer: nil,
                    cardBrand: nil,
                    state: .active,
                    lastFourDigits: lastFourDigits,
                    expiration: expiration,
                    spendableToday: nil,
                    nativeSpendableToday: nil,
                    kyc: nil,
                    panToken: cardNumber,
                    cvvToken: cvv)
    let data = card.jsonSerialize()
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<Card, NSError> in
        guard let card = json.card else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(card)
      })
    }
  }

  func issueCard(_ apiKey: String,
                 userToken: String,
                 issuer: CardIssuer,
                 custodian: Custodian?,
                 callback: @escaping Result<Card, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.pciVaultBaseUrl(), url: JSONRouter.issueVirtualCard)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    var data = [String: AnyObject]()
    data["type"] = "card" as AnyObject
    data["card_issuer"] = issuer.description().uppercased() as AnyObject
    if let custodian = custodian {
      data["custodian"] = custodian.jsonSerialize() as AnyObject
    }
    else {
      let custodian = Custodian(custodianType: .coinbase, name: "")
      custodian.externalCredentials = .oauth(OauthCredential(oauthToken: "", refreshToken: ""))
      data["custodian"] = custodian.jsonSerialize() as AnyObject
    }
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<Card, NSError> in
        guard let card = json.card else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(card)
      })
    }
  }

  func updateFinancialAccountState(_ apiKey: String,
                                   userToken: String,
                                   accountId: String,
                                   state: FinancialAccountState,
                                   callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    guard let action = state.associatedAction() else {
      return callback(.failure(BackendError(code: .incorrectParameters)))
    }
    let parameters = [
      ":accountId": accountId,
      ":action": action
    ]
    let url = URLWrapper(baseUrl: self.transport.environment.pciVaultBaseUrl(),
                         url: JSONRouter.updateFinancialAccountState,
                         urlParameters: parameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    self.transport.post(url, authorization: auth, parameters: nil, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<FinancialAccount, NSError> in
        guard let financialAccount = json.linkObject as? FinancialAccount else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(financialAccount)
      })
    }
  }

  func updateFinancialAccountPIN(_ apiKey: String,
                                 userToken: String,
                                 accountId: String,
                                 pin: String,
                                 callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.pciVaultBaseUrl(),
                         url: JSONRouter.updateFinancialAccountPIN,
                         urlParameters: [":accountId": accountId])
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    var data = [String: AnyObject]()
    data["pin"] = pin as AnyObject
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<FinancialAccount, NSError> in
        guard let financialAccount = json.linkObject as? FinancialAccount else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(financialAccount)
      })
    }
  }

  func financialAccountFundingSources(_ apiKey: String,
                                      userToken: String,
                                      accountId: String,
                                      page: Int?,
                                      rows: Int?,
                                      callback: @escaping Result<[FundingSource], NSError>.Callback) {
    var urlParameters: [String: String] = [
      ":accountId": accountId
    ]
    if let page = page {
      urlParameters["page"] = "\(page)"
    }
    if let rows = rows {
      urlParameters["rows"] = "\(rows)"
    }
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.financialAccountFundingSources,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<[FundingSource], NSError> in
        guard let fundingSources = json.linkObject as? [FundingSource] else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(fundingSources)
      })
    }
  }

  func addFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        custodian: Custodian,
                                        callback: @escaping Result<FundingSource, NSError>.Callback) {
    let urlParameters: [String: String] = [
      ":accountId": accountId
    ]
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.financialAccountFundingSources,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    var data = [String: AnyObject]()
    data["funding_source_type"] = "custodian_wallet" as AnyObject
    data["funding_source_data"] = custodian.jsonSerializeForAddFundingSource() as AnyObject
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<FundingSource, NSError> in
        guard let fundingSource = json.linkObject as? FundingSource else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(fundingSource)
      })
    }
  }
}
