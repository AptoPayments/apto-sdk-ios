//
//  ManageShiftCardInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 24/10/2017.
//
//

import Foundation

class ManageShiftCardInteractor: ManageShiftCardInteractorProtocol {
  private let shiftSession: ShiftSession
  private let accountId: String
  private var card: Card?
  private let uiConfig: ShiftUIConfig

  init(shiftSession: ShiftSession, accountId: String, uiConfig: ShiftUIConfig) {
    self.shiftSession = shiftSession
    self.accountId = accountId
    self.uiConfig = uiConfig
  }

  func provideCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    self.shiftSession.currentUser { userResult in
      switch userResult {
      case .failure(let error):
        callback(.failure(error))
      case .success(let user):
        self.shiftSession.getFinancialAccount(accountId: self.accountId) { result in
          callback(result.flatMap { financialAccount -> Result<Card, NSError> in
            guard let card = financialAccount as? Card else {
              return .failure(ServiceError(code: .jsonError))
            }
            card.cardHolder = user.userData.nameDataPoint.fullName()
            self.card = card
            return .success(card)
          })
        }
      }
    }
  }

  func activateCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    if let card = self.card {
      shiftSession.shiftCardSession.activate(card: card, callback: callback)
    }
    else {
      // This shouldn't happen!
      callback(.failure(ServiceError(code: .notInitialized)))
    }
  }

  func provideTransactions(rows: Int,
                           lastTransactionId: String?,
                           callback: @escaping Result<[Transaction], NSError>.Callback) {
    if let card = self.card {
      shiftSession.shiftCardSession.cardTransactions(card: card,
                                                     page: nil,
                                                     rows: rows,
                                                     lastTransactionId: lastTransactionId,
                                                     callback: callback)
    }
    else {
      self.provideCard { result in
        switch result {
        case .failure(let error):
          callback(.failure(error))
        case .success(let card):
          self.shiftSession.shiftCardSession.cardTransactions(card: card,
                                                              page: nil,
                                                              rows: rows,
                                                              lastTransactionId: lastTransactionId,
                                                              callback: callback)
        }
      }
    }
  }
}
