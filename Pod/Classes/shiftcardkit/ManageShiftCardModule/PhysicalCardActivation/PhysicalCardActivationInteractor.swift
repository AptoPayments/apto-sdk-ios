//
// PhysicalCardActivationInteractor.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-12-10.
//

import Foundation

class PhysicalCardActivationInteractor: PhysicalCardActivationInteractorProtocol {
  private let card: Card
  private let session: ShiftSession

  init(card: Card, session: ShiftSession) {
    self.card = card
    self.session = session
  }

  func fetchCard(callback: @escaping Result<Card, NSError>.Callback) {
    callback(.success(card))
  }

  func fetchCurrentUser(callback: @escaping Result<ShiftUser, NSError>.Callback) {
    session.currentUser(callback: callback)
  }

  func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    session.shiftCardSession.activatePhysical(card: card, code: code) { result in
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
}
