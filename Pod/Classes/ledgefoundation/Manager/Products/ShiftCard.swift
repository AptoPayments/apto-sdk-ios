//
//  ShiftCard.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 07/03/2018.
//

import Foundation

extension ShiftPlatform {
  // MARK: - Public Methods
  func issueCard(_ accessToken: AccessToken,
                 issuer: CardIssuer,
                 custodian: Custodian? = nil,
                 callback: @escaping Result<Card, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.issueCard(projectKey,
                                       userToken: accessToken.token,
                                       issuer: issuer,
                                       custodian: custodian,
                                       callback: callback)
  }

  func activateCard(_ accessToken: AccessToken,
                    accountId: String,
                    callback: @escaping Result<Card, NSError>.Callback) {
    self.changeCardState(accessToken, accountId: accountId, state: .created, callback: callback)
  }

  func unlockCard(_ accessToken: AccessToken,
                  accountId: String,
                  callback: @escaping Result<Card, NSError>.Callback) {
    self.changeCardState(accessToken, accountId: accountId, state: .active, callback: callback)
  }

  func lockCard(_ accessToken: AccessToken,
                accountId: String,
                callback: @escaping Result<Card, NSError>.Callback) {
    self.changeCardState(accessToken, accountId: accountId, state: .inactive, callback: callback)
  }

  func changeCardPIN(_ accessToken: AccessToken,
                     accountId: String,
                     pin: String,
                     callback: @escaping Result<Card, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.updateFinancialAccountPIN(projectKey,
                                                       userToken: accessToken.token,
                                                       accountId: accountId,
                                                       pin: pin) { result in
      callback(result.flatMap { financialAccount -> Result<Card, NSError> in
        guard let card = financialAccount as? Card else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(card)
      })
    }
  }

  func cardTransactions(_ accessToken: AccessToken,
                        accountId: String,
                        page: Int?,
                        rows: Int?,
                        lastTransactionId: String?,
                        callback: @escaping Result<[Transaction], NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.getFinancialAccountTransactions(projectKey,
                                                             userToken: accessToken.token,
                                                             accountId: accountId,
                                                             page: page,
                                                             rows: rows,
                                                             lastTransactionId: lastTransactionId,
                                                             callback: callback)
  }

  fileprivate func changeCardState(_ accessToken: AccessToken,
                                   accountId: String,
                                   state: FinancialAccountState,
                                   callback: @escaping Result<Card, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.updateFinancialAccountState(projectKey,
                                                         userToken: accessToken.token,
                                                         accountId: accountId,
                                                         state: state) { result in
      callback(result.flatMap { financialAccount -> Result<Card, NSError> in
        guard let card = financialAccount as? Card else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(card)
      })
    }
  }

  func financialAccountFundingSources(_ accessToken: AccessToken,
                                      accountId: String,
                                      page: Int?,
                                      rows: Int?,
                                      callback: @escaping Result<[FundingSource], NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.financialAccountFundingSources(projectKey,
                                                            userToken: accessToken.token,
                                                            accountId: accountId,
                                                            page: page,
                                                            rows: rows,
                                                            callback: callback)
  }

  func getCardFundingSource(accessToken: AccessToken,
                            accountId: String,
                            callback: @escaping Result<FundingSource?, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.getFinancialAccountFundingSource(projectKey,
                                                              userToken: accessToken.token,
                                                              accountId: accountId,
                                                              callback: callback)
  }

  func setCardFundingSource(accessToken: AccessToken,
                            fundingSourceId: String,
                            accountId: String,
                            callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.setFinancialAccountFundingSource(projectKey,
                                                              userToken: accessToken.token,
                                                              accountId: accountId,
                                                              fundingSourceId: fundingSourceId,
                                                              callback: callback)
  }

  func addFinancialAccountFundingSource(_ accessToken: AccessToken,
                                        accountId: String,
                                        custodian: Custodian,
                                        callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.addFinancialAccountFundingSource(projectKey,
                                                              userToken: accessToken.token,
                                                              accountId: accountId,
                                                              custodian: custodian,
                                                              callback: callback)
  }

  func cardConfiguration(forceRefresh: Bool = false,
                         callback: @escaping Result<ShiftCardConfiguration, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    configurationStorage.cardConfiguration(projectKey, forceRefresh: forceRefresh, callback: callback)
  }

  func setShiftCardOptions(shiftCardOptions: ShiftCardOptions) {
    configurationStorage.setShiftCardOptions(shiftCardOptions: shiftCardOptions)
  }

  func nextCardApplications(_ accessToken: AccessToken,
                            page: Int,
                            rows: Int,
                            callback: @escaping Result<[CardApplication], NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.nextApplications(projectKey,
                                             userToken: accessToken.token,
                                             page: page,
                                             rows: rows,
                                             callback: callback)
  }

  func applyToCard(_ accessToken: AccessToken,
                   cardProduct: ShiftCardProduct,
                   callback: @escaping Result<CardApplication, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.createApplication(projectKey,
                                              userToken: accessToken.token,
                                              cardProduct: cardProduct,
                                              callback: callback)
  }

  func cardApplicationStatus(_ accessToken: AccessToken,
                             applicationId: String,
                             callback: @escaping Result<CardApplication, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.applicationStatus(projectKey,
                                              userToken: accessToken.token,
                                              applicationId: applicationId,
                                              callback: callback)
  }

  func setBalanceStore(_ accessToken: AccessToken,
                       applicationId: String,
                       custodian: Custodian,
                       callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.setBalanceStore(projectKey,
                                            userToken: accessToken.token,
                                            applicationId: applicationId,
                                            custodian: custodian,
                                            callback: callback)
  }

  func acceptDisclaimer(_ accessToken: AccessToken,
                        workflowObject: WorkflowObject,
                        workflowAction: WorkflowAction,
                        callback: @escaping Result<Void, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.acceptDisclaimer(projectKey,
                                             userToken: accessToken.token,
                                             workflowObject: workflowObject,
                                             workflowAction: workflowAction,
                                             callback: callback)
  }

  func issueCard(_ accessToken: AccessToken,
                 applicationId: String,
                 balanceVersion: BalanceVersion,
                 callback: @escaping Result<Card, NSError>.Callback) {
    guard let projectKey = self.apiKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.issueCard(projectKey,
                                      userToken: accessToken.token,
                                      applicationId: applicationId,
                                      balanceVersion: balanceVersion,
                                      callback: callback)
  }
}

extension ShiftSession {
  func issueCard(issuer: CardIssuer, custodian: Custodian? = nil, callback: @escaping Result<Card, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().issueCard(accessToken,
                                             issuer: issuer,
                                             custodian: custodian,
                                             callback: callback)
  }

  func addFinancialAccountFundingSource(accountId: String,
                                        custodian: Custodian,
                                        callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().addFinancialAccountFundingSource(accessToken,
                                                                    accountId: accountId,
                                                                    custodian: custodian,
                                                                    callback: callback)
  }
}
