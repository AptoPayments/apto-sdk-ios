//
//  ShiftCardTransactionDetailsInteractor.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import Foundation

class ShiftCardTransactionDetailsInteractor: ShiftCardTransactionDetailsInteractorProtocol {

  let shiftSession: ShiftSession
  let transaction: Transaction

  init(shiftSession: ShiftSession, transaction: Transaction) {
    self.shiftSession = shiftSession
    self.transaction = transaction
  }

  func provideTransaction(callback: @escaping Result<Transaction, NSError>.Callback) {
    callback(.success(transaction))
  }

}
