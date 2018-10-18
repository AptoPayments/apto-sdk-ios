//
//  DisplayCardInteractor.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 24/10/2017.
//
//

import Foundation

class DisplayCardInteractor: DisplayCardInteractorProtocol {

  let shiftSession: ShiftSession
  let accountId: String
  let initialCardAmount: Amount?

  init(shiftSession:ShiftSession, accountId: String, initialCardAmount: Amount?) {
    self.shiftSession = shiftSession
    self.accountId = accountId
    self.initialCardAmount = initialCardAmount
  }

  func provideCard(_ callback:@escaping Result<Card, NSError>.Callback) {
    self.shiftSession.currentUser() { userResult in
      switch userResult {
      case .failure(let error):
        callback(.failure(error))
      case .success(let user):
        self.shiftSession.getFinancialAccount(accountId: self.accountId, retrieveBalance: false) { result in
          callback(result.flatMap { financialAccount -> Result<Card, NSError> in
            guard let card = financialAccount as? Card else {
              return .failure(ServiceError(code: .jsonError))
            }
            if card.fundingSource?.balance == nil {
              card.fundingSource = FundingSource(fundingSourceId: "",
                                                 type: .custodianWallet,
                                                 balance: self.initialCardAmount,
                                                 amountHold: nil,
                                                 state: .valid)
            }
            card.cardHolder = user.userData.nameDataPoint.fullName()
            return .success(card)
          })
        }
      }
    }
  }

}
