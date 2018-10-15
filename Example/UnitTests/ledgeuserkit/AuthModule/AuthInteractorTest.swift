//
//  AuthInteractorTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 14/06/2018.
//
//

import XCTest
@testable import ShiftSDK

class AuthInteractorTest: XCTestCase {
  private var sut: AuthInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator: ServiceLocatorFake = ServiceLocatorFake()
  private let dataProvider: ModelDataProvider = ModelDataProvider.provider
  private lazy var authConfig: AuthModuleConfig = AuthModuleConfig(primaryAuthCredential: .phoneNumber,
                                                                   secondaryAuthCredential: .email,
                                                                   allowedCountries: [dataProvider.usa])
  private let dataReceiver: AuthDataReceiverSpy = AuthDataReceiverSpy()

  override func setUp() {
    super.setUp()

    givenPhonePrimaryCredential()
  }

  func testProvideAuthDataSetData() {
    // When
    sut.provideAuthData()

    // Then
    XCTAssertTrue(dataReceiver.setUserDataCalled)
    XCTAssertEqual(sut.internalUserData, dataReceiver.lastUserDataSet)
    XCTAssertEqual(authConfig.primaryAuthCredential, dataReceiver.lastPrimaryCredentialSet)
    XCTAssertEqual(authConfig.secondaryAuthCredential, dataReceiver.lastSecondaryCredentialSet)
  }
}

// MARK: - nextTapped
extension AuthInteractorTest {
  func testNextTappedWithPhoneAsPrimaryCredentialAskToShowPhoneVerification() {
    // When
    sut.nextTapped()

    // Then
    XCTAssertTrue(dataReceiver.showPhoneVerificationCalled)
    XCTAssertNotNil(dataReceiver.lastPhoneVerificationType)
  }

  func testNextTappedWithEmailAsPrimaryCredentialAskToShowEmailVerification() {
    // Given
    givenEmailPrimaryCredential()

    // When
    sut.nextTapped()

    // Then
    XCTAssertTrue(dataReceiver.showEmailVerificationCalled)
    XCTAssertNotNil(dataReceiver.lastEmailVerificationType)
  }

  func testNextTappedWithBirthDateAsPrimaryCredentialAskToShowBirthDateVerification() {
    // Given
    givenBirthDatePrimaryCredential()

    // When
    sut.nextTapped()

    // Then
    XCTAssertTrue(dataReceiver.showBirthdateVerificationCalled)
    XCTAssertNotNil(dataReceiver.lastBirthdateVerificationType)
  }

  func testNextTappedWithUnsupportedPrimaryCredentialAskToShowError() {
    // Given
    givenSSNPrimaryCredential()

    // When
    sut.nextTapped()

    // Then
    XCTAssertTrue(dataReceiver.showErrorCalled)
    XCTAssertNotNil(dataReceiver.lastErrorShown)
  }
}

// MARK: - Phone verification
extension AuthInteractorTest {
  func testPhoneIsPrimaryCredentialOfNewUserVerificationSucceededCreateUserCalled() {
    // Given
    let verification = Verification(verificationId: "",
                                    verificationType: .phoneNumber,
                                    status: .passed)

    // When
    sut.phoneVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(serviceLocator.sessionFake.createUserCalled)
  }

  func testPhoneIsPrimaryCredentialOfNewUserCreateUserFailedShowError() {
    // Given
    givenPhonePrimaryCredential()
    let verification = Verification(verificationId: "",
                                    verificationType: .phoneNumber,
                                    status: .passed)
    serviceLocator.setUpSessionForCreateUserFailure()

    // When
    sut.phoneVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.showErrorCalled)
  }

  func testPhoneIsPrimaryCredentialOfNewUserCreateUserSucceededReturnExistingUser() {
    // Given
    givenPhonePrimaryCredential()
    let verification = Verification(verificationId: "",
                                    verificationType: .phoneNumber,
                                    status: .passed)
    serviceLocator.setUpSessionForCreateUserSuccess()

    // When
    sut.phoneVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.returnExistingUserWithUserDataCalled)
    XCTAssertNotNil(dataReceiver.lastExistingUser)
  }

  func testPhoneIsPrimaryCredentialOfExistingUserVerificationSucceededShowSecondaryCredentialVerification() {
    // Given
    let secondaryVerification = Verification(verificationId: "",
                                             verificationType: .email,
                                             status: .pending)
    let verification = Verification(verificationId: "",
                                    verificationType: .phoneNumber,
                                    status: .passed,
                                    secret: nil,
                                    secondaryCredential: secondaryVerification)

    // When
    sut.phoneVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.showEmailVerificationCalled)
    XCTAssertNotNil(dataReceiver.lastEmailVerificationType)
  }

  func testPhoneIsSecondaryCredentialOfExistingUserVerificationSucceededRecoverUserFailsShowError() {
    // Given
    serviceLocator.setUpSessionForLoginUserWithVerificationFailure()
    givenEmailPrimaryCredential()
    sut.internalUserData.emailDataPoint.verification = Verification(verificationId: "",
                                                                    verificationType: .email,
                                                                    status: .passed)
    let verification = Verification(verificationId: "",
                                    verificationType: .phoneNumber,
                                    status: .passed)

    // When
    sut.phoneVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.showErrorCalled)
    XCTAssertNotNil(dataReceiver.lastErrorShown)
  }

  func testPhoneIsSecondaryCredentialOfExistingUserVerificationSucceededRecoverUserSucceedReturnUser() {
    // Given
    serviceLocator.setUpSessionForLoginUserWithVerificationSuccess()
    givenEmailPrimaryCredential()
    sut.internalUserData.emailDataPoint.verification = Verification(verificationId: "",
                                                                    verificationType: .email,
                                                                    status: .passed)
    let verification = Verification(verificationId: "",
                                    verificationType: .phoneNumber,
                                    status: .passed)

    // When
    sut.phoneVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.returnExistingUserWithUserDataCalled)
    XCTAssertNotNil(dataReceiver.lastExistingUser)
  }

  func testPhoneVerificationPendingPhoneVerificationFailed() {
    // Given
    let phoneDataPoint = sut.internalUserData.phoneDataPoint
    phoneDataPoint.verification = Verification(verificationId: "",
                                               verificationType: .phoneNumber,
                                               status: .pending)

    // When
    sut.phoneVerificationFailed()

    // Then
    XCTAssertEqual(.failed, phoneDataPoint.verification!.status) // swiftlint:disable:this force_unwrapping
  }
}

// MARK: - Email verification
extension AuthInteractorTest {
  func testEmailIsPrimaryCredentialOfNewUserVerificationSucceededCallCreateUser() {
    // Given
    givenEmailPrimaryCredential()
    let verification = Verification(verificationId: "",
                                    verificationType: .email,
                                    status: .passed)

    // When
    sut.emailVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(serviceLocator.sessionFake.createUserCalled)
  }

  func testEmailIsPrimaryCredentialOfNewUserCreateUserFailedShowError() {
    // Given
    givenEmailPrimaryCredential()
    let verification = Verification(verificationId: "",
                                    verificationType: .email,
                                    status: .passed)
    serviceLocator.setUpSessionForCreateUserFailure()

    // When
    sut.emailVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.showErrorCalled)
  }

  func testEmailIsPrimaryCredentialOfNewUserCreateUserSucceededReturnExistingUser() {
    // Given
    givenEmailPrimaryCredential()
    let verification = Verification(verificationId: "",
                                    verificationType: .email,
                                    status: .passed)
    serviceLocator.setUpSessionForCreateUserSuccess()

    // When
    sut.emailVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.returnExistingUserWithUserDataCalled)
    XCTAssertNotNil(dataReceiver.lastExistingUser)
  }

  func testEmailIsPrimaryCredentialOfExistingUserVerificationSucceededShowSecondaryCredentialVerification() {
    // Given
    givenEmailPrimaryCredential()
    let secondaryVerification = Verification(verificationId: "",
                                             verificationType: .phoneNumber,
                                             status: .pending)
    let verification = Verification(verificationId: "",
                                    verificationType: .email,
                                    status: .passed,
                                    secret: nil,
                                    secondaryCredential: secondaryVerification)

    // When
    sut.emailVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.showPhoneVerificationCalled)
    XCTAssertNotNil(dataReceiver.lastPhoneVerificationType)
  }

  func testEmailIsSecondaryCredentialOfExistingUserVerificationSucceededRecoverUserFailsShowError() {
    // Given
    serviceLocator.setUpSessionForLoginUserWithVerificationFailure()
    givenPhonePrimaryCredential()
    sut.internalUserData.phoneDataPoint.verification = Verification(verificationId: "",
                                                                    verificationType: .phoneNumber,
                                                                    status: .passed)
    let verification = Verification(verificationId: "",
                                    verificationType: .email,
                                    status: .passed)

    // When
    sut.emailVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.showErrorCalled)
    XCTAssertNotNil(dataReceiver.lastErrorShown)
  }

  func testEmailIsSecondaryCredentialOfExistingUserVerificationSucceededRecoverUserSucceedReturnUser() {
    // Given
    serviceLocator.setUpSessionForLoginUserWithVerificationSuccess()
    givenPhonePrimaryCredential()
    sut.internalUserData.phoneDataPoint.verification = Verification(verificationId: "",
                                                                    verificationType: .phoneNumber,
                                                                    status: .passed)
    let verification = Verification(verificationId: "",
                                    verificationType: .email,
                                    status: .passed)

    // When
    sut.emailVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.returnExistingUserWithUserDataCalled)
    XCTAssertNotNil(dataReceiver.lastExistingUser)
  }

  func testEmailVerificationPendingEmailVerificationFailed() {
    // Given
    let emailDataPoint = sut.internalUserData.emailDataPoint
    emailDataPoint.verification = Verification(verificationId: "",
                                               verificationType: .email,
                                               status: .pending)

    // When
    sut.emailVerificationFailed()

    // Then
    XCTAssertEqual(.failed, emailDataPoint.verification!.status) // swiftlint:disable:this force_unwrapping
  }
}

// MARK: - Birth date verification
extension AuthInteractorTest {
  func testBirthDateIsPrimaryCredentialOfNewUserVerificationSucceededCallCreateUser() {
    // Given
    givenBirthDatePrimaryCredential()
    let verification = Verification(verificationId: "",
                                    verificationType: .birthDate,
                                    status: .passed)

    // When
    sut.birthdateVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(serviceLocator.sessionFake.createUserCalled)
  }

  func testBirthDateIsPrimaryCredentialOfNewUserCreateUserFailedShowError() {
    // Given
    givenBirthDatePrimaryCredential()
    let verification = Verification(verificationId: "",
                                    verificationType: .birthDate,
                                    status: .passed)
    serviceLocator.setUpSessionForCreateUserFailure()

    // When
    sut.birthdateVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.showErrorCalled)
  }

  func testBirthDateIsPrimaryCredentialOfNewUserCreateUserSucceededReturnExistingUser() {
    // Given
    givenBirthDatePrimaryCredential()
    let verification = Verification(verificationId: "",
                                    verificationType: .birthDate,
                                    status: .passed)
    serviceLocator.setUpSessionForCreateUserSuccess()

    // When
    sut.birthdateVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.returnExistingUserWithUserDataCalled)
    XCTAssertNotNil(dataReceiver.lastExistingUser)
  }

  func testBirthDateIsPrimaryCredentialOfExistingUserVerificationSucceededShowSecondaryCredentialVerification() {
    // Given
    givenBirthDatePrimaryCredential()
    let secondaryVerification = Verification(verificationId: "",
                                             verificationType: .email,
                                             status: .pending)
    let verification = Verification(verificationId: "",
                                    verificationType: .birthDate,
                                    status: .passed,
                                    secret: nil,
                                    secondaryCredential: secondaryVerification)

    // When
    sut.birthdateVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.showEmailVerificationCalled)
    XCTAssertNotNil(dataReceiver.lastEmailVerificationType)
  }

  func testBirthDateIsSecondaryCredentialOfExistingUserVerificationSucceededRecoverUserFailsShowError() {
    // Given
    serviceLocator.setUpSessionForLoginUserWithVerificationFailure()
    givenBirthDateSecondaryCredential()
    sut.internalUserData.emailDataPoint.verification = Verification(verificationId: "",
                                                                    verificationType: .email,
                                                                    status: .passed)
    let verification = Verification(verificationId: "",
                                    verificationType: .birthDate,
                                    status: .passed)

    // When
    sut.birthdateVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.showErrorCalled)
    XCTAssertNotNil(dataReceiver.lastErrorShown)
  }

  func testBirthDateIsSecondaryCredentialOfExistingUserVerificationSucceededRecoverUserSucceedReturnUser() {
    // Given
    serviceLocator.setUpSessionForLoginUserWithVerificationSuccess()
    givenBirthDateSecondaryCredential()
    sut.internalUserData.emailDataPoint.verification = Verification(verificationId: "",
                                                                    verificationType: .email,
                                                                    status: .passed)
    let verification = Verification(verificationId: "",
                                    verificationType: .birthDate,
                                    status: .passed)

    // When
    sut.birthdateVerificationSucceeded(verification)

    // Then
    XCTAssertTrue(dataReceiver.returnExistingUserWithUserDataCalled)
    XCTAssertNotNil(dataReceiver.lastExistingUser)
  }

  func testBirthDateVerificationPendingBirthDateVerificationFailed() {
    // Given
    givenBirthDatePrimaryCredential()
    let birthDateDataPoint = sut.internalUserData.birthDateDataPoint
    birthDateDataPoint.verification = Verification(verificationId: "",
                                                   verificationType: .birthDate,
                                                   status: .pending)

    // When
    sut.birthdateVerificationFailed()

    // Then
    XCTAssertEqual(.failed, birthDateDataPoint.verification!.status) // swiftlint:disable:this force_unwrapping
  }
}

private extension AuthInteractorTest {
  func givenPhonePrimaryCredential() {
    sut = AuthInteractor(session: serviceLocator.session,
                         initialUserData: dataProvider.phoneNumberDataPointList,
                         config: authConfig,
                         dataReceiver: dataReceiver)
  }

  func givenEmailPrimaryCredential() {
    sut = AuthInteractor(session: serviceLocator.session,
                         initialUserData: dataProvider.emailDataPointList,
                         config: AuthModuleConfig(primaryAuthCredential: .email,
                                                  secondaryAuthCredential: .phoneNumber,
                                                  allowedCountries: [dataProvider.usa]),
                         dataReceiver: dataReceiver)
  }

  func givenBirthDatePrimaryCredential() {
    sut = AuthInteractor(session: serviceLocator.session,
                         initialUserData: dataProvider.birthDateDataPointList,
                         config: AuthModuleConfig(primaryAuthCredential: .birthDate,
                                                  secondaryAuthCredential: .email,
                                                  allowedCountries: [dataProvider.usa]),
                         dataReceiver: dataReceiver)
  }

  func givenBirthDateSecondaryCredential() {
    sut = AuthInteractor(session: serviceLocator.session,
                         initialUserData: dataProvider.birthDateDataPointList,
                         config: AuthModuleConfig(primaryAuthCredential: .email,
                                                  secondaryAuthCredential: .birthDate,
                                                  allowedCountries: [dataProvider.usa]),
                         dataReceiver: dataReceiver)
  }

  func givenSSNPrimaryCredential() {
    sut = AuthInteractor(session: serviceLocator.session,
                         initialUserData: dataProvider.ssnDataPointList,
                         config: AuthModuleConfig(primaryAuthCredential: .idDocument,
                                                  secondaryAuthCredential: .email,
                                                  allowedCountries: [dataProvider.usa]),
                         dataReceiver: dataReceiver)
  }
}
