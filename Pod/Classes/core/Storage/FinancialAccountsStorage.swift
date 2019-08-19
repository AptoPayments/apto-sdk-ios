//
//  FinancialAccountsStorage.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 19/10/2016.
//
//

import Foundation

public struct TransactionListFilters {
  let page: Int?
  let rows: Int?
  let lastTransactionId: String?
  let startDate: Date?
  let endDate: Date?
  let mccCode: String?
  let states: [TransactionState]?

  public init(page: Int? = nil, rows: Int? = nil, lastTransactionId: String? = nil, startDate: Date? = nil,
              endDate: Date? = nil, mccCode: String? = nil, states: [TransactionState]? = nil) {
    self.page = page
    self.rows = rows
    self.lastTransactionId = lastTransactionId
    self.startDate = startDate
    self.endDate = endDate
    self.mccCode = mccCode
    self.states = states
  }

  func encoded() -> [String: String] {
    var dictionary = [String: String]()
    if let page = self.page {
      dictionary["page"] = String(page)
    }
    if let rows = self.rows {
      dictionary["rows"] = String(rows)
    }
    if let lastTransactionId = self.lastTransactionId {
      dictionary["last_transaction_id"] = lastTransactionId
    }
    if let startDate = self.startDate {
      dictionary["start_date"] = startDate.formatForJSONAPI()
    }
    if let endDate = self.endDate {
      dictionary["end_date"] = endDate.formatForJSONAPI()
    }
    if let mccCode = self.mccCode {
      dictionary["mcc"] = mccCode
    }
    if let states = self.states {
      dictionary["state"] = encodeStates(states)
    }
    return dictionary
  }

  private func encodeStates(_ states: [TransactionState]) -> String {
    guard !states.isEmpty else { return "null" }
    var encodedStates = states[0].rawValue
    states.dropFirst().forEach { encodedStates.append(contentsOf: "&state=\($0.rawValue)") }
    return encodedStates
  }
}

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
                           forceRefresh: Bool,
                           retrieveBalances: Bool,
                           callback: @escaping Result<FinancialAccount, NSError>.Callback)
  func getCardDetails(_ apiKey: String,
                      userToken: String,
                      accountId: String,
                      callback: @escaping Result<CardDetails, NSError>.Callback)
  func getFinancialAccountTransactions(_ apiKey: String,
                                       userToken: String,
                                       accountId: String,
                                       filters: TransactionListFilters,
                                       forceRefresh: Bool,
                                       callback: @escaping Result<[Transaction], NSError>.Callback)
  func getFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        forceRefresh: Bool,
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
  func activatePhysical(_ apiKey: String,
                        userToken: String,
                        accountId: String,
                        code: String,
                        callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback)
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
                                      forceRefresh: Bool,
                                      callback: @escaping Result<[FundingSource], NSError>.Callback)
  func addFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        custodian: Custodian,
                                        callback: @escaping Result<FundingSource, NSError>.Callback)
  func monthlySpending(_ apiKey: String,
                       userToken: String,
                       accountId: String,
                       date: Date,
                       callback: @escaping Result<MonthlySpending, NSError>.Callback)

  func issueCard(_ apiKey: String, userToken: String, cardProduct: CardProduct, custodian: Custodian?,
                 balanceVersion: BalanceVersion, callback: @escaping Result<Card, NSError>.Callback)
}

extension FinancialAccountsStorageProtocol {
  func getFinancialAccount(_ apiKey: String,
                           userToken: String,
                           accountId: String,
                           forceRefresh: Bool = true,
                           retrieveBalances: Bool = false,
                           callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    getFinancialAccount(apiKey,
                        userToken: userToken,
                        accountId: accountId,
                        forceRefresh: forceRefresh,
                        retrieveBalances: retrieveBalances,
                        callback: callback)
  }

  func getFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        forceRefresh: Bool = true,
                                        callback: @escaping Result<FundingSource?, NSError>.Callback) {
    getFinancialAccountFundingSource(apiKey,
                                     userToken: userToken,
                                     accountId: accountId,
                                     forceRefresh: forceRefresh,
                                     callback: callback)
  }

  func getFinancialAccountTransactions(_ apiKey: String,
                                       userToken: String,
                                       accountId: String,
                                       filters: TransactionListFilters,
                                       forceRefresh: Bool = true,
                                       callback: @escaping Result<[Transaction], NSError>.Callback) {
    getFinancialAccountTransactions(apiKey,
                                    userToken: userToken,
                                    accountId: accountId,
                                    filters: filters,
                                    forceRefresh: forceRefresh,
                                    callback: callback)
  }

  func financialAccountFundingSources(_ apiKey: String,
                                      userToken: String,
                                      accountId: String,
                                      page: Int?,
                                      rows: Int?,
                                      forceRefresh: Bool = true,
                                      callback: @escaping Result<[FundingSource], NSError>.Callback) {
    financialAccountFundingSources(apiKey,
                                   userToken: userToken,
                                   accountId: accountId,
                                   page: page,
                                   rows: rows,
                                   forceRefresh: forceRefresh,
                                   callback: callback)
  }
}

class FinancialAccountsStorage: FinancialAccountsStorageProtocol {
  private let transport: JSONTransport
  private let cache: FinancialAccountCacheProtocol

  init(transport: JSONTransport, cache: FinancialAccountCacheProtocol) {
    self.transport = transport
    self.cache = cache
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
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.financialAccounts)
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
                           forceRefresh: Bool = true,
                           retrieveBalances: Bool = false,
                           callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    if forceRefresh == false, let card = cache.cachedCard(accountId: accountId), card.cardProductId != nil {
      if retrieveBalances == true, card.fundingSource == nil {
        getFinancialAccountFundingSource(apiKey,
                                         userToken: userToken,
                                         accountId: accountId,
                                         forceRefresh: false) { result in
          switch result {
          case .failure(let error):
            callback(.failure(error))
          case .success(let fundingSource):
            card.fundingSource = fundingSource
            callback(.success(card))
          }
        }
        return
      }
      callback(.success(card))
      return
    }
    let urlParameters = [
      "show_details": "false",
      "refresh_balances": retrieveBalances ? "true" : "false"
    ]
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(),
                         url: JSONRouter.financialAccounts,
                         urlTrailing: accountId,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let json):
        guard let financialAccount = json.linkObject as? FinancialAccount else {
          callback(.failure(ServiceError(code: .jsonError)))
          return
        }
        self.cache.saveCard(financialAccount)
        if retrieveBalances == true, let card = financialAccount as? Card, card.cardIssuer == .shift {
          self.getFinancialAccountFundingSource(apiKey,
                                                userToken: userToken,
                                                accountId: accountId,
                                                forceRefresh: forceRefresh) { [weak self] result in
            callback(result.flatMap { fundingSource -> Result<FinancialAccount, NSError> in
              card.fundingSource = fundingSource
              self?.cache.saveCard(card)
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

  func getCardDetails(_ apiKey: String,
                      userToken: String,
                      accountId: String,
                      callback: @escaping Result<CardDetails, NSError>.Callback) {
    let urlParameters = [":accountId": accountId]
    let url = URLWrapper(baseUrl: transport.environment.pciVaultBaseUrl(),
                         url: JSONRouter.financialAccountsDetails,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.get(url, authorization: auth,
                  parameters: nil,
                  headers: nil,
                  acceptRedirectTo: nil,
                  filterInvalidTokenResult: true) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let json):
        guard let cardDetails = json.cardDetails else {
          callback(.failure(ServiceError(code: .jsonError)))
          return
        }
        callback(.success(cardDetails))
      }
    }
  }

  func getFinancialAccountTransactions(_ apiKey: String,
                                       userToken: String,
                                       accountId: String,
                                       filters: TransactionListFilters,
                                       forceRefresh: Bool = true,
                                       callback: @escaping Result<[Transaction], NSError>.Callback) {
    if forceRefresh == false, let transactions = cache.cachedTransactions(accountId: accountId), !transactions.isEmpty {
      callback(.success(transactions))
      return
    }
    var urlParameters = filters.encoded()
    urlParameters[":accountId"] = accountId
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.financialAccountTransactions,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { [weak self] result in
      callback(result.flatMap { json -> Result<[Transaction], NSError> in
        guard let transactions = json.linkObject as? [Transaction] else {
          return .failure(ServiceError(code: .jsonError))
        }
        self?.cache.saveTransactions(transactions, accountId: accountId)
        return .success(transactions)
      })
    }
  }

  func getFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        forceRefresh: Bool = true,
                                        callback: @escaping Result<FundingSource?, NSError>.Callback) {
    if forceRefresh == false, let cachedFundingSource = cache.cachedFundingSource(accountId: accountId) {
      callback(.success(cachedFundingSource))
      return
    }
    let urlParameters = [":accountId": accountId]
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.financialAccountFundingSource,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { [weak self] result in
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
        self?.cache.saveFundingSource(fundingSource, accountId: accountId)
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
    transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { [weak self] result in
      callback(result.flatMap { json -> Result<FundingSource, NSError> in
        guard let fundingSource = json.linkObject as? FundingSource else {
          return .failure(ServiceError(code: .jsonError))
        }
        self?.cache.saveFundingSource(fundingSource, accountId: accountId)
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

  func activatePhysical(_ apiKey: String,
                        userToken: String,
                        accountId: String,
                        code: String,
                        callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback) {
    let parameters = [
      "code": code as AnyObject
    ]
    let urlParameters = [
      ":accountId": accountId,
      "show_details": "false",
      "refresh_spendable_today": "false"
    ]
    let url = URLWrapper(baseUrl: transport.baseUrl(),
                         url: JSONRouter.activatePhysicalCard,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<PhysicalCardActivationResult, NSError> in
        guard let result = json.physicalCardActivationResult else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(result)
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
      ":action": action,
      "show_details": "false",
      "refresh_spendable_today": "false"
    ]
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
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
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
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
                                      forceRefresh: Bool = true,
                                      callback: @escaping Result<[FundingSource], NSError>.Callback) {
    if forceRefresh == false, let fundingSources = cache.cachedFundingSources(accountId: accountId) {
      callback(.success(fundingSources))
      return
    }
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
                       filterInvalidTokenResult: true) { [weak self] result in
      callback(result.flatMap { json -> Result<[FundingSource], NSError> in
        guard let fundingSources = json.linkObject as? [FundingSource] else {
          return .failure(ServiceError(code: .jsonError))
        }
        self?.cache.saveFundingSources(fundingSources, accountId: accountId)
        return .success(fundingSources)
      })
    }
  }

  func addFinancialAccountFundingSource(_ apiKey: String,
                                        userToken: String,
                                        accountId: String,
                                        custodian: Custodian,
                                        callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let credentials = custodian.externalCredentials, case let .oauth(oauthCredentials) = credentials else {
      callback(.failure(BackendError(code: .incorrectParameters)))
      return
    }
    let urlParameters: [String: String] = [
      ":accountId": accountId
    ]
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.financialAccountFundingSources,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    let data: [String: AnyObject] = [
      "funding_source_type": "custodian_wallet" as AnyObject,
      "oauth_token_id": oauthCredentials.oauthTokenId as AnyObject
    ]
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let json):
        guard let fundingSource = json.fundingSource else {
          return callback(.failure(ServiceError(code: .jsonError)))
        }
        return callback(.success(fundingSource))
      }
    }
  }

  private let months = [
    "january", "february", "march", "april", "may", "june",
    "july", "august", "september", "october", "november", "december"
  ]
  func monthlySpending(_ apiKey: String,
                       userToken: String,
                       accountId: String,
                       date: Date,
                       callback: @escaping Result<MonthlySpending, NSError>.Callback) {
    let urlParameters: [String: String] = [
      ":accountId": accountId,
      ":month": months[date.month - 1],
      ":year": String(date.year)
    ]
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.financialAccountMonthlySpending,
                         urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<MonthlySpending, NSError> in
        guard let spending = json.monthlySpending else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(spending)
      })
    }
  }

  func issueCard(_ apiKey: String, userToken: String, cardProduct: CardProduct, custodian: Custodian?,
                 balanceVersion: BalanceVersion, callback: @escaping Result<Card, NSError>.Callback) {
    var data: [String: AnyObject] = [
      "type": "card" as AnyObject,
      "card_product_id": cardProduct.id as AnyObject,
      "balance_version": balanceVersion.rawValue as AnyObject
    ]
    if let custodian = custodian {
      data.merge(custodian.asJson, uniquingKeysWith: { $1 })
    }
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .issueCard)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let json):
        guard let card = json.card else {
          callback(.failure(ServiceError(code: .jsonError)))
          return
        }
        callback(.success(card))
      }
    }
  }
}