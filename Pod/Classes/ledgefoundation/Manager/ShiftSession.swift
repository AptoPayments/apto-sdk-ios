//
//  ShiftSession.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 12/10/2016.
//
//

import Foundation
import Bond

open class ShiftSession: NSObject {
  private let shiftPlatform: ShiftPlatform
  var initialModule: UIModuleProtocol?

  // MARK: Merchant Data
  open var merchantData = MerchantData()

  // MARK: Current User Data
  fileprivate var internalCurrentUser: ShiftUser?

  public init(shiftPlatform: ShiftPlatform = ShiftPlatform.defaultManager()) {
    self.shiftPlatform = shiftPlatform
    super.init()
  }

  @objc override public convenience init() {
    self.init(shiftPlatform: ShiftPlatform.defaultManager())
  }

  func createUser(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    shiftPlatform.createUser(userData: userData) { [weak self] result in
      callback(result.flatMap { currentUser -> Result<ShiftUser, NSError> in
        self?.internalCurrentUser = currentUser
        return .success(currentUser)
      })
    }
  }

  func loginUserWith(verifications: [Verification], callback: @escaping Result<ShiftUser, NSError>.Callback) {
    shiftPlatform.loginUserWith(verifications: verifications) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success:
        self.currentUser(true) { result in
          switch result {
          case .failure(let error):
            callback(.failure(error))
          case .success (let newUser):
            self.internalCurrentUser = newUser
            callback(.success(newUser))
          }
        }
      }
    }
  }

  func logout() {
    shiftPlatform.clearUserToken()
    internalCurrentUser = nil
    NotificationCenter.default.post(Notification(name: .UserTokenSessionClosedNotification,
                                                 object: nil,
                                                 userInfo: nil))
  }

  func updateUserData(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let accessToken = shiftPlatform.currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    if userData.dataPoints.isEmpty {
      self.currentUser { result in
        callback(result.flatMap { currentUser -> Result<ShiftUser, NSError> in
          return .success(currentUser)
        })
      }
    }
    else {
      shiftPlatform.updateUserInfo(accessToken, userData: userData) { result in
        callback(result.flatMap { currentUser -> Result<ShiftUser, NSError> in
          self.internalCurrentUser = currentUser
          return .success(currentUser)
        })
      }
    }
  }

  func currentUser(_ forceRefresh: Bool = false,
                   filterInvalidTokenResult: Bool = true,
                   callback: @escaping Result<ShiftUser, NSError>.Callback) {
    if internalCurrentUser != nil && forceRefresh == false {
      callback(.success(internalCurrentUser!)) // swiftlint:disable:this force_unwrapping
      return
    }
    guard let accessToken = shiftPlatform.currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    shiftPlatform.currentUserInfo(accessToken, filterInvalidTokenResult: filterInvalidTokenResult) { result in
      callback(result.flatMap { currentUser -> Result<ShiftUser, NSError> in
        self.internalCurrentUser = currentUser
        return .success(currentUser)
      })
    }
  }

  func getAuthorisationHeaders(_ callback: Result<[String: String]?, NSError>.Callback) {
    shiftPlatform.authorisationHeaders(callback)
  }

  func getPlaidURL(_ callback: Result<URL, NSError>.Callback) {
    shiftPlatform.getPlaidURL(callback)
  }

  func startPhoneVerification(_ phone: PhoneNumber, callback: @escaping Result<Verification, NSError>.Callback) {
    shiftPlatform.startPhoneVerification(phone, callback: callback)
  }

  func startEmailVerification(_ email: Email, callback: @escaping Result<Verification, NSError>.Callback) {
    shiftPlatform.startEmailVerification(email, callback: callback)
  }

  func startBirthDateVerification(_ birthDate: BirthDate, callback: @escaping Result<Verification, NSError>.Callback) {
    shiftPlatform.startBirthDateVerification(birthDate, callback: callback)
  }

  func startDocumentVerification(_ documentImages: [UIImage],
                                 selfie: UIImage?,
                                 livenessData: [String: AnyObject]?,
                                 associatedTo workflowObject: WorkflowObject?,
                                 callback: @escaping Result<Verification, NSError>.Callback) {
    guard let accessToken = shiftPlatform.currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    shiftPlatform.startDocumentVerification(accessToken,
                                            documentImages: documentImages,
                                            selfie: selfie,
                                            livenessData: livenessData,
                                            associatedTo: workflowObject,
                                            callback: callback)
  }

  func documentVerificationStatus(_ verification: Verification,
                                  callback: @escaping Result<Verification, NSError>.Callback) {
    shiftPlatform.documentVerificationStatus(verification, callback: callback)
  }

  func restartVerification(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback) {
    shiftPlatform.restartVerification(verification, callback: callback)
  }

  func addBankAccounts(_ publicToken: String, callback: @escaping Result<[BankAccount], NSError>.Callback) {
    guard let accessToken = shiftPlatform.currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    shiftPlatform.addBankAccounts(accessToken, publicToken: publicToken, callback: callback)
  }

  func completeVerification(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback) {
    shiftPlatform.completeVerification(verification, callback: callback)
  }

  func verificationStatus(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback) {
    shiftPlatform.verificationStatus(verification, callback: callback)
  }

  func nextFinancialAccounts(_ page: Int, rows: Int, callback: @escaping Result<[FinancialAccount], NSError>.Callback) {
    guard let accessToken = shiftPlatform.currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    shiftPlatform.nextFinancialAccounts(accessToken, page: page, rows: rows, callback: callback)
  }

  func getFinancialAccount(accountId: String,
                           retrieveBalance: Bool = true,
                           callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    guard let accessToken = shiftPlatform.currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    shiftPlatform.getFinancialAccount(accessToken,
                                      accountId: accountId,
                                      retrieveBalance: retrieveBalance,
                                      callback: callback)
  }

  func addCard(cardNumber: String,
               cardNetwork: CardNetwork,
               expirationMonth: UInt,
               expirationYear: UInt,
               cvv: String,
               callback: @escaping Result<Card, NSError>.Callback) {
    guard let accessToken = shiftPlatform.currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    shiftPlatform.addCard(accessToken,
                          cardNumber: cardNumber,
                          cardNetwork: cardNetwork,
                          expirationMonth: expirationMonth,
                          expirationYear: expirationYear,
                          cvv: cvv,
                          callback: callback)
  }

  open func currentUserToken() -> AccessToken? {
    return shiftPlatform.currentToken()
  }

  open func currentPushToken() -> String? {
    return shiftPlatform.currentPushToken()
  }

  open func existingUser() -> Bool {
    return shiftPlatform.currentToken() != nil
  }

  open func contextConfiguration(_ forceRefresh: Bool = false,
                                 callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    shiftPlatform.contextConfiguration(forceRefresh) { [weak self] result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let contextConfiguration):
        // Check if the primary and secondary credentials are the same used to retrieve the current user's token. If
        // they're not, invalidate that token
        if let primaryCredential = self?.currentUserToken()?.primaryCredential,
          let secondaryCredential = self?.currentUserToken()?.secondaryCredential {
          if (contextConfiguration.projectConfiguration.primaryAuthCredential != primaryCredential)
               || (contextConfiguration.projectConfiguration.secondaryAuthCredential != secondaryCredential) {
            self?.shiftPlatform.clearUserToken()
          }
        }
        callback(.success(contextConfiguration))
      }
    }
  }

  open func bankOauthConfiguration(_ forceRefresh: Bool = false,
                                   callback: @escaping Result<BankOauthConfiguration, NSError>.Callback) {
    guard let accessToken = shiftPlatform.currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    shiftPlatform.bankOauthConfiguration(accessToken, forceRefresh: forceRefresh, callback: callback)
  }

  func startOauthAuthentication(_ custodianType: CustodianType,
                                callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    guard let accessToken = shiftPlatform.currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    shiftPlatform.startOauthAuthentication(accessToken, custodianType: custodianType, callback: callback)
  }

  func verifyOauthAttemptStatus(_ attempt: OauthAttempt,
                                custodianType: CustodianType,
                                callback: @escaping Result<Custodian, NSError>.Callback) {
    guard let accessToken = shiftPlatform.currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    shiftPlatform.verifyOauthAttemptStatus(accessToken,
                                           attempt: attempt,
                                           custodianType: custodianType,
                                           callback: callback)
  }
}
