//
//  VerifyEmailInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 02/10/2016.
//
//

import Foundation

protocol VerifyEmailDataReceiver: class {
  func emailReceived(_ email: Email)
  func unknownEmail()
  func verificationReceived(_ verification: Verification)
  func sendPinSuccess()
  func sendPinError(_ error: NSError)
  func pinVerificationSucceeded(_ verification: Verification)
  func pinVerificationFailed()
}

class VerifyEmailInteractor: VerifyEmailInteractorProtocol {

  unowned let dataReceiver: VerifyEmailDataReceiver
  let verificationType: VerificationParams<Email, Verification>
  let session: ShiftSession
  var email: Email?
  var verification: Verification?

  init(session: ShiftSession, verificationType: VerificationParams<Email, Verification>, dataReceiver: VerifyEmailDataReceiver) {
    self.session = session
    self.dataReceiver = dataReceiver
    self.verificationType = verificationType
  }

  func provideEmail() {
    switch verificationType {
    case .datapoint(let email):
      self.email = email
      dataReceiver.emailReceived(email)
      sendPin()
    case .verification(let verification):
      self.verification = verification
      self.dataReceiver.verificationReceived(verification)
    }
  }

  func sendPin() {
    guard let email = self.email else {
      return
    }
    self.session.startEmailVerification(email) { result in
      switch result {
      case .failure(let error):
        self.dataReceiver.sendPinError(error)
      case .success(let verification):
        self.verification = verification
        self.dataReceiver.verificationReceived(verification)
        self.dataReceiver.sendPinSuccess()
      }
    }
  }

  func resendPin() {
    guard let verification = self.verification else {
      return
    }
    self.session.restartVerification(verification) { result in
      switch result {
      case .failure(let error):
        self.dataReceiver.sendPinError(error)
      case .success(let verification):
        self.verification = verification
        self.dataReceiver.verificationReceived(verification)
        self.dataReceiver.sendPinSuccess()
      }
    }
  }

  func submitPin(_ pin: String) {
    guard let verification = self.verification else {
      return
    }
    verification.secret = pin
    self.session.completeVerification(verification) { result in
      switch result {
      case .failure:
        self.dataReceiver.pinVerificationFailed()
      case .success(let verification):
        if verification.status == .passed {
          verification.secret = pin
          self.dataReceiver.pinVerificationSucceeded(verification)
        }
        else {
          self.dataReceiver.pinVerificationFailed()
        }
      }
    }
  }

}
