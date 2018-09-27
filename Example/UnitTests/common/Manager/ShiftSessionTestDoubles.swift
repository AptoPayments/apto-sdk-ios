//
//  ShiftSessionTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 10/06/2018.
//
//

@testable import ShiftSDK

class ShiftSessionSpy: ShiftSession {
  private(set) var contextConfigurationCalled = false
  private(set) var lastContextConfigurationForceRefresh: Bool?
  private(set) var lastContextConfigurationCompletion: Result<ContextConfiguration, NSError>.Callback?
  override func contextConfiguration(_ forceRefresh: Bool,
                                     callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    contextConfigurationCalled = true
    lastContextConfigurationForceRefresh = forceRefresh
    lastContextConfigurationCompletion = callback
  }

  private(set) var createUserCalled = false
  private(set) var lastCreateUserData: DataPointList?
  private(set) var lastCreateUserCompletion: (Result<ShiftUser, NSError>.Callback)?
  override func createUser(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    createUserCalled = true
    lastCreateUserData = userData
    lastCreateUserCompletion = callback
  }

  private(set) var loginUserWithVerificationsCalled = false
  private(set) var lastLoginVerifications: [Verification]?
  private(set) var lastLoginCompletion: Result<ShiftUser, NSError>.Callback?
  override func loginUserWith(verifications: [Verification], callback: @escaping Result<ShiftUser, NSError>.Callback) {
    loginUserWithVerificationsCalled = true
    lastLoginVerifications = verifications
    lastLoginCompletion = callback
  }

  private(set) var startOauthAuthenticationCalled = false
  private(set) var lastStartOauthCustodianType: CustodianType?
  private(set) var lastStartOauthAuthenticationCallback: Result<OauthAttempt, NSError>.Callback?
  override func startOauthAuthentication(_ custodianType: CustodianType,
                                         callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    startOauthAuthenticationCalled = true
    lastStartOauthCustodianType = custodianType
    lastStartOauthAuthenticationCallback = callback
  }

  private(set) var verifyOauthAttemptStatusCalled = false
  private(set) var lastVerifyOauthCustodianType: CustodianType?
  private(set) var lastVerifyOauthAttemptStatusCallback: Result<Custodian, NSError>.Callback?
  override func verifyOauthAttemptStatus(_ attempt: OauthAttempt,
                                         custodianType: CustodianType,
                                         callback: @escaping Result<Custodian, NSError>.Callback) {
    verifyOauthAttemptStatusCalled = true
    lastVerifyOauthCustodianType = custodianType
    lastVerifyOauthAttemptStatusCallback = callback
  }
}

class ShiftSessionFake: ShiftSessionSpy {
  lazy var shiftCardSessionFake: ShiftCardSessionFake = ShiftCardSessionFake(shiftSession: self)
  @discardableResult func setUpShiftCardSession() -> ShiftCardSessionFake {
    shiftCardSession = shiftCardSessionFake

    return shiftCardSessionFake
  }

  var nextContextConfigurationResult: Result<ContextConfiguration, NSError>?
  override func contextConfiguration(_ forceRefresh: Bool,
                                     callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    super.contextConfiguration(forceRefresh, callback: callback)

    if let result = nextContextConfigurationResult {
      callback(result)
    }
  }

  var nextCreateUserResult: Result<ShiftUser, NSError>?
  override func createUser(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    super.createUser(userData, callback: callback)

    if let result = nextCreateUserResult {
      callback(result)
    }
  }

  var nextLoginUserResult: Result<ShiftUser, NSError>?
  override func loginUserWith(verifications: [Verification], callback: @escaping Result<ShiftUser, NSError>.Callback) {
    super.loginUserWith(verifications: verifications, callback: callback)

    if let result = nextLoginUserResult {
      callback(result)
    }
  }

  var nextStartOauthAuthenticationResult: Result<OauthAttempt, NSError>?
  override func startOauthAuthentication(_ custodianType: CustodianType,
                                         callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    super.startOauthAuthentication(custodianType, callback: callback)

    if let result = nextStartOauthAuthenticationResult {
      callback(result)
    }
  }

  var nextVerifyOauthAttemptStatusResult: Result<Custodian, NSError>?
  override func verifyOauthAttemptStatus(_ attempt: OauthAttempt,
                                         custodianType: CustodianType,
                                         callback: @escaping Result<Custodian, NSError>.Callback) {
    super.verifyOauthAttemptStatus(attempt, custodianType: custodianType, callback: callback)

    if let result = nextVerifyOauthAttemptStatusResult {
      callback(result)
    }
  }
}
