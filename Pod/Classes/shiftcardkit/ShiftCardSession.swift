//
//  ShiftCardSession.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 02/18/2018.
//
//

import Bond

class ShiftCardSession {

  // MARK: Access to the global shift session
  unowned let shiftSession: ShiftSession

  init(shiftSession: ShiftSession) {
    self.shiftSession = shiftSession
  }

  // MARK: Private methods
  func shiftCardConfiguration(_ forceRefresh: Bool = false,
                              callback: @escaping Result<ShiftCardConfiguration, NSError>.Callback) {
    ShiftPlatform.defaultManager().cardConfiguration(forceRefresh: forceRefresh) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let cardConfiguration):
        callback(.success(cardConfiguration))
      }
    }
  }

  /**
   * Used to store the options passed from the host app to the Card Module
   *
   * - Parameters:
   *   - shiftCardOptions: The options sent during Card Module initialization
   */
  func setShiftCardOptions(shiftCardOptions: ShiftCardOptions) {
    ShiftPlatform.defaultManager().setShiftCardOptions(shiftCardOptions: shiftCardOptions)
  }

  func applyToCardProduct(_ cardProduct: ShiftCardProduct,
                          callback: @escaping Result<CardApplication, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    ShiftPlatform.defaultManager().applyToCard(accessToken, cardProduct: cardProduct, callback: callback)
  }

  func applicationStatus(_ applicationId: String, callback: @escaping Result<CardApplication, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }

    ShiftPlatform.defaultManager().cardApplicationStatus(accessToken, applicationId: applicationId, callback: callback)
  }

  func setBalanceStore(_ applicationId: String,
                       custodian: Custodian,
                       callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().setBalanceStore(accessToken,
                                                   applicationId: applicationId,
                                                   custodian: custodian,
                                                   callback: callback)
  }

  func acceptDisclaimer(_ workflowObject: WorkflowObject,
                        workflowAction: WorkflowAction,
                        callback: @escaping Result<Void, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    ShiftPlatform.defaultManager().acceptDisclaimer(accessToken,
                                                    workflowObject: workflowObject,
                                                    workflowAction: workflowAction,
                                                    callback: callback)
  }

  func cancelCardApplication(_ applicationId: String, callback: @escaping Result<Void, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    ShiftPlatform.defaultManager().cancelCardApplication(accessToken, applicationId: applicationId, callback: callback)
  }

  func issueCard(_ applicationId: String,
                 callback: @escaping Result<Card, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    self.shiftCardConfiguration { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let shiftCardConfiguration):
        let balanceVersion: BalanceVersion = shiftCardConfiguration.isFeatureEnabled(.useBalanceVersionV2) ? .v2 : .v1
        ShiftPlatform.defaultManager().issueCard(accessToken,
                                                 applicationId: applicationId,
                                                 balanceVersion: balanceVersion,
                                                 callback: callback)
      }
    }
  }

  func getCards(_ page: Int, rows: Int, callback: @escaping Result<[Card], NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      // If no user is logged in, return an empty list
      callback(.success([]))
      return
    }
    ShiftPlatform.defaultManager().next(financialAccountsOfType: .card,
                                        accessToken: accessToken,
                                        page: page,
                                        rows: rows) { result in
      callback(result.flatMap { financialAccounts -> Result<[Card], NSError> in
        // swiftlint:disable:next force_cast
        return .success(financialAccounts.map { financialAccount -> Card in return financialAccount as! Card })
      })
    }
  }

  func activatePhysical(card: Card,
                        code: String,
                        callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    ShiftPlatform.defaultManager().activatePhysicalCard(accessToken,
                                                        accountId: card.accountId,
                                                        code: code,
                                                        callback: callback)
  }

  func activate(card: Card, callback: @escaping Result<Card, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().activateCard(accessToken, accountId: card.accountId, callback: callback)
  }

  func unlock(card: Card, callback: @escaping Result<Card, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().unlockCard(accessToken, accountId: card.accountId, callback: callback)
  }

  func lock(card: Card, callback: @escaping Result<Card, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().lockCard(accessToken, accountId: card.accountId, callback: callback)
  }

  func changeCard(card: Card, pin: String, callback: @escaping Result<Card, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().changeCardPIN(accessToken, accountId: card.accountId, pin: pin, callback: callback)
  }

  func cardTransactions(card: Card,
                        page: Int?,
                        rows: Int?,
                        lastTransactionId: String?,
                        forceRefresh: Bool = true,
                        callback: @escaping Result<[Transaction], NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().cardTransactions(accessToken,
                                                    accountId: card.accountId,
                                                    page: page,
                                                    rows: rows,
                                                    lastTransactionId: lastTransactionId,
                                                    forceRefresh: forceRefresh,
                                                    callback: callback)
  }

  func cardFundingSources(card: Card,
                          page: Int?,
                          rows: Int?,
                          forceRefresh: Bool = true,
                          callback: @escaping Result<[FundingSource], NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().financialAccountFundingSources(accessToken,
                                                                  accountId: card.accountId,
                                                                  page: page,
                                                                  rows: rows,
                                                                  forceRefresh: forceRefresh,
                                                                  callback: callback)
  }

  func getCardFundingSource(card: Card,
                            forceRefresh: Bool = true,
                            callback: @escaping Result<FundingSource?, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().getCardFundingSource(accessToken: accessToken,
                                                        accountId: card.accountId,
                                                        forceRefresh: forceRefresh,
                                                        callback: callback)
  }

  func setCardFundingSource(card: Card,
                            fundingSource: FundingSource,
                            callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().setCardFundingSource(accessToken: accessToken,
                                                        fundingSourceId: fundingSource.fundingSourceId,
                                                        accountId: card.accountId, callback: callback)
  }

}

private var shiftCardSessionDataAssociationKey: UInt8 = 0

extension ShiftSession {
  var shiftCardSession: ShiftCardSession {
    get {
      guard let retVal = objc_getAssociatedObject(self, &shiftCardSessionDataAssociationKey) as? ShiftCardSession else {
        let shiftCardSessionData = ShiftCardSession(shiftSession: self)
        objc_setAssociatedObject(self,
                                 &shiftCardSessionDataAssociationKey,
                                 shiftCardSessionData,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return shiftCardSessionData
      }
      return retVal
    }
    set(newValue) {
      objc_setAssociatedObject(self,
                               &shiftCardSessionDataAssociationKey,
                               newValue,
                               objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
  }
}
