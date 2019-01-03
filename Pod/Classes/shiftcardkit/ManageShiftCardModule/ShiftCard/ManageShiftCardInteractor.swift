//
//  ManageShiftCardInteractor.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 24/10/2017.
//
//

import Foundation

class ManageShiftCardInteractor: ManageShiftCardInteractorProtocol {
  private let shiftSession: ShiftSession
  private var card: Card

  init(shiftSession: ShiftSession, card: Card) {
    self.shiftSession = shiftSession
    self.card = card
  }

  func provideFundingSource(forceRefresh: Bool, callback: @escaping Result<Card, NSError>.Callback) {
    shiftSession.shiftCardSession.getCardFundingSource(card: card, forceRefresh: forceRefresh) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let fundingSource):
        self.card.fundingSource = fundingSource
        callback(.success(self.card))
      }
    }
  }

  func reloadCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    shiftSession.getFinancialAccount(accountId: self.card.accountId, retrieveBalances: true) { result in
      callback(result.flatMap { financialAccount -> Result<Card, NSError> in
        guard let card = financialAccount as? Card else {
          return .failure(ServiceError(code: .jsonError))
        }
        self.card = card
        return .success(card)
      })
    }
  }

  func loadCardInfo(_ callback: @escaping Result<CardDetails, NSError>.Callback) {
    shiftSession.getCardDetails(accountId: card.accountId, callback: callback)
  }

  func activateCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    shiftSession.shiftCardSession.activate(card: card, callback: callback)
  }

  func provideTransactions(rows: Int,
                           lastTransactionId: String?,
                           forceRefresh: Bool,
                           callback: @escaping Result<[Transaction], NSError>.Callback) {
    shiftSession.shiftCardSession.cardTransactions(card: card,
                                                   page: nil,
                                                   rows: rows,
                                                   lastTransactionId: lastTransactionId,
                                                   forceRefresh: forceRefresh,
                                                   callback: callback)
  }

  func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    shiftSession.shiftCardSession.activatePhysical(card: card, code: code) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let activationResult):
        if activationResult.type == .activated {
          callback(.success(Void()))
        }
        else {
          let error: BackendError
          if let rawErrorCode = activationResult.errorCode,
             let errorCode = BackendError.ErrorCodes(rawValue: rawErrorCode) {
            error = BackendError(code: errorCode)
          }
          else {
            // This should never happen
            error = BackendError(code: .other)
          }
          callback(.failure(error))
        }
      }
    }
  }

  func loadFundingSources(callback: @escaping Result<[FundingSource], NSError>.Callback) {
    shiftSession.shiftCardSession.cardFundingSources(card: card, page: nil, rows: nil, callback: callback)
  }
}
