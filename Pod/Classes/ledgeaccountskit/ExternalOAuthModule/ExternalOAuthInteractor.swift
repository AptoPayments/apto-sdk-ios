//
//  ExternalOAuthInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation

class ExternalOAuthInteractor: ExternalOAuthInteractorProtocol {

  let shiftSession: ShiftSession
  weak var presenter: ExternalOAuthPresenterProtocol!

  private var attempt: OauthAttempt?
  private var custodianType: CustodianType?

  init(shiftSession: ShiftSession) {
    self.shiftSession = shiftSession
  }

  func custodianSelected(custodianType: CustodianType) {
    self.custodianType = custodianType
    shiftSession.startOauthAuthentication(custodianType) { result in
      switch result {
      case .failure(let error):
        self.presenter.show(error: error)
      case .success(let attempt):
        self.attempt = attempt
        self.presenter.show(url: attempt.url!) // swiftlint:disable:this force_unwrapping
      }
    }
  }

  func custodianAuthenticationSucceed() {
    guard let attempt = self.attempt, let custodianType = self.custodianType else {
      return
    }
    shiftSession.verifyOauthAttemptStatus(attempt, custodianType: custodianType) { result in
      switch result {
      case .failure(let error):
        self.presenter.show(error: error)
      case .success(let custodian):
        self.presenter.custodianSelected(custodian)
      }
    }
  }
}
