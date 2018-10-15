//
//  AuthPresenterTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 15/06/2018.
//
//

import XCTest
@testable import ShiftSDK

class AuthPresenterTest: XCTestCase {
  var sut: AuthPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private lazy var dataProvider: ModelDataProvider = ModelDataProvider.provider
  private lazy var authConfig: AuthModuleConfig = AuthModuleConfig(primaryAuthCredential: .email,
                                                                   secondaryAuthCredential: .phoneNumber,
                                                                   allowedCountries: [dataProvider.usa])
  private lazy var uiConfig: ShiftUIConfig = dataProvider.uiConfig
  private let viewController: AuthViewControllerSpy = AuthViewControllerSpy()
  private let interactor: AuthInteractorSpy = AuthInteractorSpy()
  private let router: AuthRouterFake = AuthRouterFake()

  override func setUp() {
    super.setUp()

    sut = AuthPresenter(config: authConfig, uiConfig: uiConfig)
    sut.viewController = viewController
    sut.interactor = interactor
    sut.router = router
  }

  func testViewLoadedCallInteractorToProvideData() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.provideAuthDataCalled)
  }

  func testSetUserDataConfigureViewController() {
    // Given
    let userData = dataProvider.phoneNumberDataPointList

    // When
    sut.set(userData,
            primaryCredentialType: authConfig.primaryAuthCredential,
            secondaryCredentialType: authConfig.secondaryAuthCredential)

    // Then
    XCTAssertTrue(viewController.showFieldsCalled)
    XCTAssertTrue(viewController.setTitleCalled)
    XCTAssertTrue(viewController.showNavCancelButtonCalled)
    XCTAssertTrue(viewController.showNavNextButtonWithTitleCalled)
    XCTAssertTrue(viewController.updateProgressCalled)
  }

  func testNextTappedCallInteractor() {
    // When
    sut.nextTapped()

    // Then
    XCTAssertTrue(interactor.nextTappedCalled)
  }

  func testCloseTappedCallRouter() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }

  func testShowErrorCallViewControllerToShowError() {
    // Given
    let error = NSError(domain: "com.shiftpayments.error", code: 1)

    // When
    sut.show(error: error)

    // Then
    XCTAssertTrue(viewController.showErrorCalled)
    XCTAssertEqual(error, viewController.lastErrorShown! as NSError) // swiftlint:disable:this force_unwrapping
  }

  func testReturnExistingUserWithUserDataCallRouter() {
    // Given
    let user = ShiftUser(userId: "userId", accessToken: AccessToken(token: "token",
                                                                    primaryCredential: .phoneNumber,
                                                                    secondaryCredential: .email))

    // When
    sut.returnExistingUser(user)

    // Then
    XCTAssertTrue(router.returnExistingUserWithUserDataCalled)
    XCTAssertEqual(user, router.lastExistingUser)
  }
}

// MARK: - Phone verification
extension AuthPresenterTest {
  func testShowPhoneVerificationCallRouterToPresentPhoneVerification() {
    // Given
    let verificationParams = VerificationParams.datapoint(PhoneNumber())

    // When
    sut.showPhoneVerification(verificationType: verificationParams)

    // Then
    XCTAssertTrue(router.presentPhoneVerificationCalled)
    XCTAssertNotNil(router.lastPhoneVerificationParams)
    XCTAssertNotNil(router.lastPhoneVerificationCompletion)
  }

  func testShowPhoneVerificationRouterFinishWithSuccessNotifySuccessToInteractor() {
    // Given
    let verificationParams = VerificationParams.datapoint(PhoneNumber())
    let verification = Verification(verificationId: "", verificationType: .phoneNumber, status: .passed)
    router.nextPhoneVerificationResult = .success(verification)

    // When
    sut.showPhoneVerification(verificationType: verificationParams)

    // Then
    XCTAssertTrue(interactor.phoneVerificationSucceededCalled)
    XCTAssertEqual(verification, interactor.lastPhoneVerification)
  }

  func testShowPhoneVerificationRouterFinishWithFailureNotifyFailureToInteractor() {
    // Given
    let verificationParams = VerificationParams.datapoint(PhoneNumber())
    router.nextPhoneVerificationResult = .failure(NSError(domain: "com.shiftpayments.error", code: 1))

    // When
    sut.showPhoneVerification(verificationType: verificationParams)

    // Then
    XCTAssertTrue(interactor.phoneVerificationFailedCalled)
  }
}

// MARK: - Email verification
extension AuthPresenterTest {
  func testShowEmailVerificationCallRouterToPresentEmailVerification() {
    // Given
    let verificationParams = VerificationParams.datapoint(Email())

    // When
    sut.showEmailVerification(verificationType: verificationParams)

    // Then
    XCTAssertTrue(router.presentEmailVerificationCalled)
    XCTAssertNotNil(router.lastEmailVerificationParams)
    XCTAssertNotNil(router.lastEmailVerificationCompletion)
  }

  func testShowEmailVerificationRouterFinishWithSuccessNotifySuccessToInteractor() {
    // Given
    let verificationParams = VerificationParams.datapoint(Email())
    let verification = Verification(verificationId: "", verificationType: .email, status: .passed)
    router.nextEmailVerificationResult = .success(verification)

    // When
    sut.showEmailVerification(verificationType: verificationParams)

    // Then
    XCTAssertTrue(interactor.emailVerificationSucceededCalled)
    XCTAssertEqual(verification, interactor.lastEmailVerification)
  }

  func testShowEmailVerificationRouterFinishWithFailureNotifyFailureToInteractor() {
    // Given
    let verificationParams = VerificationParams.datapoint(Email())
    router.nextEmailVerificationResult = .failure(NSError(domain: "com.shiftpayments.error", code: 1))

    // When
    sut.showEmailVerification(verificationType: verificationParams)

    // Then
    XCTAssertTrue(interactor.emailVerificationFailedCalled)
  }
}

// MARK: - Birth date verification
extension AuthPresenterTest {
  func testShowBirthDateVerificationCallRouterToPresentBirthDateVerification() {
    // Given
    let verificationParams = VerificationParams.datapoint(BirthDate())

    // When
    sut.showBirthdateVerification(verificationType: verificationParams)

    // Then
    XCTAssertTrue(router.presentBirthdateVerificationCalled)
    XCTAssertNotNil(router.lastBirthdateVerificationParams)
    XCTAssertNotNil(router.lastBirthdateVerificationCompletion)
  }

  func testShowBirthDateVerificationRouterFinishWithSuccessNotifySuccessToInteractor() {
    // Given
    let verificationParams = VerificationParams.datapoint(BirthDate())
    let verification = Verification(verificationId: "", verificationType: .birthDate, status: .passed)
    router.nextBirthDateVerificationResult = .success(verification)

    // When
    sut.showBirthdateVerification(verificationType: verificationParams)

    // Then
    XCTAssertTrue(interactor.birthdateVerificationSucceededCalled)
    XCTAssertEqual(verification, interactor.lastBirthdateVerification)
  }

  func testShowBirthDateVerificationRouterFinishWithFailureNotifyFailureToInteractor() {
    // Given
    let verificationParams = VerificationParams.datapoint(BirthDate())
    router.nextBirthDateVerificationResult = .failure(NSError(domain: "com.shiftpayments.error", code: 1))

    // When
    sut.showBirthdateVerification(verificationType: verificationParams)

    // Then
    XCTAssertTrue(interactor.birthdateVerificationFailedCalled)
  }
}
