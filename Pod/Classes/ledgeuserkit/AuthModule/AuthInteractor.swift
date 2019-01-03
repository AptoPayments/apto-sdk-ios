//
//  AuthInteractor.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/12/2017.
//

class AuthInteractor: AuthInteractorProtocol {

  let session: ShiftSession
  unowned let dataReceiver: AuthDataReceiver
  let config: AuthModuleConfig
  var internalUserData: DataPointList

  // MARK: - Initialization

  init(session: ShiftSession,
       initialUserData: DataPointList,
       config: AuthModuleConfig,
       dataReceiver: AuthDataReceiver) {
    self.session = session
    self.internalUserData = initialUserData.copy() as! DataPointList // swiftlint:disable:this force_cast
    self.dataReceiver = dataReceiver
    self.config = config
  }

  // MARK: - AuthInteractorProtocol protocol

  func provideAuthData() {
    self.dataReceiver.set(self.internalUserData,
                          primaryCredentialType: self.config.primaryAuthCredential,
                          secondaryCredentialType: self.config.secondaryAuthCredential)
  }

  func nextTapped() {
    switch config.primaryAuthCredential {
    case .phoneNumber:
      guard let phoneDataPoint = internalUserData.getDataPointsOf(type: .phoneNumber)?.first as? PhoneNumber else {
        dataReceiver.show(error: ServiceError(code: .internalIncosistencyError, reason: "Phone not available"))
        return
      }
      dataReceiver.showPhoneVerification(verificationType: .datapoint(phoneDataPoint))
    case .email:
      guard let emailDataPoint = internalUserData.getDataPointsOf(type: .email)?.first as? Email else {
        dataReceiver.show(error: ServiceError(code: .internalIncosistencyError, reason: "Email not available"))
        return
      }
      dataReceiver.showEmailVerification(verificationType: .datapoint(emailDataPoint))
    case .birthDate:
      guard let birthdateDataPoint = internalUserData.getDataPointsOf(type: .birthDate)?.first as? BirthDate else {
        dataReceiver.show(error: ServiceError(code: .internalIncosistencyError, reason: "Birthdate not available"))
        return
      }
      dataReceiver.showBirthdateVerification(verificationType: .datapoint(birthdateDataPoint))
    default:
      dataReceiver.show(error: ServiceError(code: .internalIncosistencyError,
                                            reason: "Primary Credential Type not Supported."))
    }
  }

  func phoneVerificationSucceeded(_ verification: Verification) {
    self.internalUserData.phoneDataPoint.verification = verification
    if self.config.secondaryAuthCredential == .phoneNumber {
      // This is the verification of the secondary credentials. Recover user
      self.recoverUser()
    }
    else {
      // Phone is the primary credential. See if there's a secondary credential that can be verified to recover an
      // existent user
      self.launchSecondaryCredentialVerificationOrReturn(primaryCredentialVerification: verification)
    }
  }

  func phoneVerificationFailed() {
    self.internalUserData.phoneDataPoint.verification?.status = .failed
  }

  func emailVerificationSucceeded(_ verification: Verification) {
    self.internalUserData.emailDataPoint.verification = verification
    if self.config.secondaryAuthCredential == .email {
      // This is the verification of the secondary credentials. Recover user
      self.recoverUser()
    }
    else {
      // Email is the primary credential. See if there's a secondary credential that can be verified to recover an
      // existent user
      self.launchSecondaryCredentialVerificationOrReturn(primaryCredentialVerification: verification)
    }
  }

  func emailVerificationFailed() {
    self.internalUserData.emailDataPoint.verification?.status = .failed
  }

  func birthdateVerificationSucceeded(_ verification: Verification) {
    self.internalUserData.birthDateDataPoint.verification = verification
    if self.config.secondaryAuthCredential == .birthDate {
      // This is the verification of the secondary credentials. Recover user
      self.recoverUser()
    }
    else {
      // Birthdate is the primary credential. See if there's a secondary credential that can be verified to recover an
      // existent user
      self.launchSecondaryCredentialVerificationOrReturn(primaryCredentialVerification: verification)
    }
  }

  func birthdateVerificationFailed() {
    self.internalUserData.birthDateDataPoint.verification?.status = .failed
  }

  fileprivate func launchSecondaryCredentialVerificationOrReturn(primaryCredentialVerification: Verification) {
    if let secondaryCredential = primaryCredentialVerification.secondaryCredential {
      // Existing User. Verify secondary credential
      switch secondaryCredential.verificationType {
      case .email:
        self.dataReceiver.showEmailVerification(verificationType: .verification(secondaryCredential))
      case .birthDate:
        self.dataReceiver.showBirthdateVerification(verificationType: .verification(secondaryCredential))
      case .phoneNumber:
        self.dataReceiver.showPhoneVerification(verificationType: .verification(secondaryCredential))
      default:
        break
      }
    }
    else {
      // New user.
      guard let _ = internalUserData.getDataPointsOf(type: config.primaryAuthCredential)?.first else {
        dataReceiver.show(error: ServiceError(code: .internalIncosistencyError,
                                              reason: "Primary Credential not Available"))
        return
      }
      dataReceiver.showLoadingView()
      self.session.createUser(self.internalUserData) { [weak self] result in
        self?.dataReceiver.hideLoadingView()
        switch result {
        case .failure(let error):
          self?.dataReceiver.show(error: error)
        case .success(let user):
          self?.dataReceiver.returnExistingUser(user)
        }
      }
    }
  }

  fileprivate func recoverUser() {
    guard let primaryCredentialDatapoint = internalUserData.getDataPointsOf(type: config.primaryAuthCredential)?.first,
      let secondaryCredentialDatapoint = internalUserData.getDataPointsOf(type: config.secondaryAuthCredential)?.first,
      let primaryCredentialDatapointVerification = primaryCredentialDatapoint.verification,
      let secondaryCredentialDatapointVerification = secondaryCredentialDatapoint.verification else {
        dataReceiver.show(error: ServiceError(code: .internalIncosistencyError,
                                              reason: "Can't obtain login verifications"))
        return
    }
    dataReceiver.showLoadingView()
    self.session.loginUserWith(verifications: [primaryCredentialDatapointVerification,
                                               secondaryCredentialDatapointVerification]) { [weak self] result in
      self?.dataReceiver.hideLoadingView()
      switch result {
      case .failure(let error):
        self?.dataReceiver.show(error: error)
      case .success(let user):
        self?.dataReceiver.returnExistingUser(user)
      }
    }
  }
}
