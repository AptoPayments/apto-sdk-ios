//
//  VerifyPhoneInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import Foundation

protocol VerifyPhoneDataReceiver: class {
  func phoneNumberReceived(_ phone: PhoneNumber)
  func unknownPhoneNumber()
  func verificationReceived(_ verification: Verification)
  func sendPinSuccess()
  func sendPinError(_ error: NSError)
  func pinVerificationSucceeded(_ verification: Verification)
  func pinVerificationFailed()
}

class VerifyPhoneInteractor: VerifyPhoneInteractorProtocol {
  private unowned let dataReceiver: VerifyPhoneDataReceiver
  private let verificationType: VerificationParams<PhoneNumber, Verification>
  private let session: ShiftSession
  private var phone: PhoneNumber?
  private var verification: Verification?

  init(session: ShiftSession,
       verificationType: VerificationParams<PhoneNumber, Verification>,
       dataReceiver: VerifyPhoneDataReceiver) {
    self.session = session
    self.dataReceiver = dataReceiver
    self.verificationType = verificationType
  }

  func providePhoneNumber() {
    switch verificationType {
    case .datapoint(let phone):
      self.phone = phone
      dataReceiver.phoneNumberReceived(phone)
      sendPin()
    case .verification(let verification):
      self.verification = verification
      dataReceiver.unknownPhoneNumber()
    }
  }

  func sendPin() {
    guard let phone = self.phone else {
      return
    }
    self.session.startPhoneVerification(phone) { result in
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
