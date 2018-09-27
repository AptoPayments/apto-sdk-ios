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
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.financialAccountsStorage.issueCard(developerKey,
                                            projectKey: projectKey,
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
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    self.financialAccountsStorage.updateFinancialAccountPIN(developerKey,
                                                            projectKey: projectKey,
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
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    self.financialAccountsStorage.getFinancialAccountTransactions(developerKey,
                                                                  projectKey: projectKey,
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
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    self.financialAccountsStorage.updateFinancialAccountState(developerKey,
                                                              projectKey: projectKey,
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

  func userFundingSources(_ accessToken: AccessToken,
                          page: Int?,
                          rows: Int?,
                          callback: @escaping Result<[FundingSource], NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    self.financialAccountsStorage.userFundingSources(developerKey,
                                                     projectKey: projectKey,
                                                     userToken: accessToken.token,
                                                     page: page,
                                                     rows: rows,
                                                     callback: callback)
  }

  func getCardFundingSource(accessToken: AccessToken,
                            accountId: String,
                            callback: @escaping Result<FundingSource?, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    self.financialAccountsStorage.getFinancialAccountFundingSource(developerKey,
                                                                   projectKey: projectKey,
                                                                   userToken: accessToken.token,
                                                                   accountId: accountId,
                                                                   callback: callback)
  }

  func setCardFundingSource(accessToken: AccessToken,
                            fundingSourceId: String,
                            accountId: String,
                            callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    self.financialAccountsStorage.setFinancialAccountFundingSource(developerKey,
                                                                   projectKey: projectKey,
                                                                   userToken: accessToken.token,
                                                                   accountId: accountId,
                                                                   fundingSourceId: fundingSourceId,
                                                                   callback: callback)
  }

  func addUserFundingSource(_ accessToken: AccessToken,
                            custodian: Custodian,
                            callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    self.financialAccountsStorage.addUserFundingSource(developerKey,
                                                       projectKey: projectKey,
                                                       userToken: accessToken.token,
                                                       custodian: custodian,
                                                       callback: callback)
  }

  func cardConfiguration(forceRefresh: Bool = false,
                         callback: @escaping Result<ShiftCardConfiguration, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    self.configurationStorage.cardConfiguration(developerKey,
                                                projectKey: projectKey,
                                                forceRefresh: forceRefresh,
                                                callback: callback)
  }

  func setShiftCardOptions(shiftCardOptions: ShiftCardOptions) {
    self.configurationStorage.setShiftCardOptions(shiftCardOptions: shiftCardOptions)
  }

  func nextCardApplications(_ accessToken: AccessToken,
                            page: Int,
                            rows: Int,
                            callback: @escaping Result<[CardApplication], NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.cardApplicationsStorage.nextApplications(developerKey,
                                                  projectKey: projectKey,
                                                  userToken: accessToken.token,
                                                  page: page,
                                                  rows: rows,
                                                  callback: callback)
  }

  func applyToCard(_ accessToken: AccessToken,
                   cardProduct: ShiftCardProduct,
                   callback: @escaping Result<CardApplication, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.cardApplicationsStorage.createApplication(developerKey,
                                                   projectKey: projectKey,
                                                   userToken: accessToken.token,
                                                   cardProduct: cardProduct,
                                                   callback: callback)
  }

  func cardApplicationStatus(_ accessToken: AccessToken,
                             applicationId: String,
                             callback: @escaping Result<CardApplication, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.cardApplicationsStorage.applicationStatus(developerKey,
                                                   projectKey: projectKey,
                                                   userToken: accessToken.token,
                                                   applicationId: applicationId,
                                                   callback: callback)
  }

  func setBalanceStore(_ accessToken: AccessToken,
                       applicationId: String,
                       custodian: Custodian,
                       callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.cardApplicationsStorage.setBalanceStore(developerKey,
                                                 projectKey: projectKey,
                                                 userToken: accessToken.token,
                                                 applicationId: applicationId,
                                                 custodian: custodian,
                                                 callback: callback)
  }

  func acceptDisclaimer(_ accessToken: AccessToken,
                        workflowObject: WorkflowObject,
                        workflowAction: WorkflowAction,
                        callback: @escaping Result<Void, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.acceptDisclaimer(developerKey,
                                             projectKey: projectKey,
                                             userToken: accessToken.token,
                                             workflowObject: workflowObject,
                                             workflowAction: workflowAction,
                                             callback: callback)
  }

  func issueCard(_ accessToken: AccessToken,
                 applicationId: String,
                 balanceVersion: BalanceVersion,
                 callback: @escaping Result<Card, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.issueCard(developerKey,
                                      projectKey: projectKey,
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

  func addUserFundingSource(custodian: Custodian, callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().addUserFundingSource(accessToken,
                                                        custodian: custodian,
                                                        callback: callback)
  }
}
