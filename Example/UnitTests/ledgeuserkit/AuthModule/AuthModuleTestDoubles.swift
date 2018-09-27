//
//  AuthModuleTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 14/06/2018.
//
//

@testable import ShiftSDK

class AuthRouterSpy: AuthRouterProtocol {
  private(set) var closeCalled = false
  func close() {
    closeCalled = true
  }

  private(set) var backCalled = false
  func back() {
    backCalled = true
  }

  private(set) var presentPhoneVerificationCalled = false
  private(set) var lastPhoneVerificationParams: VerificationParams<PhoneNumber, Verification>?
  private(set) var lastPhoneVerificationCompletion: (Result<Verification, NSError>.Callback)?
  func presentPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>,
                                completion: (Result<Verification, NSError>.Callback)?) {
    presentPhoneVerificationCalled = true
    lastPhoneVerificationParams = verificationType
    lastPhoneVerificationCompletion = completion
  }

  private(set) var presentEmailVerificationCalled = false
  private(set) var lastEmailVerificationParams: VerificationParams<Email, Verification>?
  private(set) var lastEmailVerificationCompletion: (Result<Verification, NSError>.Callback)?
  func presentEmailVerification(verificationType: VerificationParams<Email, Verification>,
                                completion: (Result<Verification, NSError>.Callback)?) {
    presentEmailVerificationCalled = true
    lastEmailVerificationParams = verificationType
    lastEmailVerificationCompletion = completion
  }

  private(set) var presentBirthdateVerificationCalled = false
  private(set) var lastBirthdateVerificationParams: VerificationParams<BirthDate, Verification>?
  private(set) var lastBirthdateVerificationCompletion: (Result<Verification, NSError>.Callback)?
  func presentBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>,
                                    completion: (Result<Verification, NSError>.Callback)?) {
    presentBirthdateVerificationCalled = true
    lastBirthdateVerificationParams = verificationType
    lastBirthdateVerificationCompletion = completion
  }

  private(set) var returnExistingUserWithUserDataCalled = false
  private(set) var lastExistingUser: ShiftUser?
  func returnExistingUser(_ user: ShiftUser) {
    returnExistingUserWithUserDataCalled = true
    lastExistingUser = user
  }
}

class AuthRouterFake: AuthRouterSpy {
  var nextPhoneVerificationResult: Result<Verification, NSError>?
  override func presentPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>,
                                         completion: (Result<Verification, NSError>.Callback)?) {
    super.presentPhoneVerification(verificationType: verificationType, completion: completion)

    guard let result = nextPhoneVerificationResult else { return }
    completion?(result)
  }

  var nextEmailVerificationResult: Result<Verification, NSError>?
  override func presentEmailVerification(verificationType: VerificationParams<Email, Verification>,
                                         completion: (Result<Verification, NSError>.Callback)?) {
    super.presentEmailVerification(verificationType: verificationType, completion: completion)

    guard let result = nextEmailVerificationResult else { return }
    completion?(result)
  }

  var nextBirthDateVerificationResult: Result<Verification, NSError>?
  override func presentBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>,
                                             completion: (Result<Verification, NSError>.Callback)?) {
    super.presentBirthdateVerification(verificationType: verificationType, completion: completion)

    guard let result = nextBirthDateVerificationResult else { return }
    completion?(result)
  }
}

class AuthInteractorSpy: AuthInteractorProtocol {
  private(set) var provideAuthDataCalled = false
  func provideAuthData() {
    provideAuthDataCalled = true
  }

  private(set) var nextTappedCalled = false
  func nextTapped() {
    nextTappedCalled = true
  }

  private(set) var phoneVerificationSucceededCalled = false
  private(set) var lastPhoneVerification: Verification?
  func phoneVerificationSucceeded(_ verification: Verification) {
    phoneVerificationSucceededCalled = true
    lastPhoneVerification = verification
  }

  private(set) var phoneVerificationFailedCalled = false
  func phoneVerificationFailed() {
    phoneVerificationFailedCalled = true
  }

  private(set) var emailVerificationSucceededCalled = false
  private(set) var lastEmailVerification: Verification?
  func emailVerificationSucceeded(_ verification: Verification) {
    emailVerificationSucceededCalled = true
    lastEmailVerification = verification
  }

  private(set) var emailVerificationFailedCalled = false
  func emailVerificationFailed() {
    emailVerificationFailedCalled = true
  }

  private(set) var birthdateVerificationSucceededCalled = false
  private(set) var lastBirthdateVerification: Verification?
  func birthdateVerificationSucceeded(_ verification: Verification) {
    birthdateVerificationSucceededCalled = true
    lastBirthdateVerification = verification
  }

  private(set) var birthdateVerificationFailedCalled = false
  func birthdateVerificationFailed() {
    birthdateVerificationFailedCalled = true
  }
}

class AuthViewControllerSpy: ViewControllerSpy, AuthViewProtocol {
  private(set) var showFieldsCalled = false
  private(set) var lastFields: [FormRowView]?
  func show(fields: [FormRowView]) {
    showFieldsCalled = true
    lastFields = fields
  }

  private(set) var updateProgressCalled = false
  private(set) var lastProgress: Float?
  func update(progress: Float) {
    updateProgressCalled = true
    lastProgress = progress
  }
}

class AuthDataReceiverSpy: AuthDataReceiver {
  private(set) var setUserDataCalled = false
  private(set) var lastUserDataSet: DataPointList?
  private(set) var lastPrimaryCredentialSet: DataPointType?
  private(set) var lastSecondaryCredentialSet: DataPointType?
  func set(_ userData: DataPointList, primaryCredentialType: DataPointType, secondaryCredentialType: DataPointType) {
    setUserDataCalled = true
    lastUserDataSet = userData
    lastPrimaryCredentialSet = primaryCredentialType
    lastSecondaryCredentialSet = secondaryCredentialType
  }

  private(set) var showErrorCalled = false
  private(set) var lastErrorShown: NSError?
  func show(error: NSError) {
    showErrorCalled = true
    lastErrorShown = error
  }

  private(set) var showPhoneVerificationCalled = false
  private(set) var lastPhoneVerificationType: VerificationParams<PhoneNumber, Verification>?
  func showPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>) {
    showPhoneVerificationCalled = true
    lastPhoneVerificationType = verificationType
  }

  private(set) var showEmailVerificationCalled = false
  private(set) var lastEmailVerificationType: VerificationParams<Email, Verification>?
  func showEmailVerification(verificationType: VerificationParams<Email, Verification>) {
    showEmailVerificationCalled = true
    lastEmailVerificationType = verificationType
  }

  private(set) var showBirthdateVerificationCalled = false
  private(set) var lastBirthdateVerificationType: VerificationParams<BirthDate, Verification>?
  func showBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>) {
    showBirthdateVerificationCalled = true
    lastBirthdateVerificationType = verificationType
  }

  private(set) var returnExistingUserWithUserDataCalled = false
  private(set) var lastExistingUser: ShiftUser?
  func returnExistingUser(_ user: ShiftUser) {
    returnExistingUserWithUserDataCalled = true
    lastExistingUser = user
  }
}

class AuthEventHandlerSpy: AuthDataReceiverSpy, AuthEventHandler {
  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var nextTappedCalled = false
  func nextTapped() {
    nextTappedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }
}

class AuthPresenterSpy: AuthEventHandlerSpy, AuthPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var viewController: AuthViewProtocol!
  var interactor: AuthInteractorProtocol!
  var router: AuthRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
}
