//
//  KYCInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 9/04/2018.
//
//

import Foundation

class KYCInteractor: KYCInteractorProtocol {
  private let shiftSession: ShiftSession
  private let card: Card

  init(shiftSession: ShiftSession, card: Card) {
    self.shiftSession = shiftSession
    self.card = card
  }

  func provideKYCInfo(_ callback: @escaping Result<KYCState?, NSError>.Callback) {
    shiftSession.getFinancialAccount(accountId: card.accountId, retrieveBalance: false) { result in
      callback(result.flatMap { financialAccount -> Result<KYCState?, NSError> in
        if let card = financialAccount as? Card {
          return .success(card.kyc)
        }
        else {
          return .success(nil)
        }
      })
    }
  }
}
