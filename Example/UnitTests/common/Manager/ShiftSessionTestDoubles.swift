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
  private(set) var lastStartOauthBalanceType: AllowedBalanceType?
  private(set) var lastStartOauthAuthenticationCallback: Result<OauthAttempt, NSError>.Callback?
  override func startOauthAuthentication(_ balanceType: AllowedBalanceType,
                                         callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    startOauthAuthenticationCalled = true
    lastStartOauthBalanceType = balanceType
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

  private(set) var updateUserDataCalled = false
  private(set) var lastUserDataToUpdate: DataPointList?
  private(set) var lastUpdateUserDataCallback: Result<ShiftUser, NSError>.Callback?
  override func updateUserData(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    updateUserDataCalled = true
    lastUserDataToUpdate = userData
    lastUpdateUserDataCallback = callback
  }

  private(set) var getFinancialAccountCalled = false
  private(set) var lastGetFinancialAccountId: String?
  private(set) var lastGetFinancialAccountForceRefresh: Bool?
  private(set) var lastGetFinancialAccountRetrieveBalances: Bool?
  override func getFinancialAccount(accountId: String,
                                    forceRefresh: Bool = true,
                                    retrieveBalances: Bool = false,
                                    callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    getFinancialAccountCalled = true
    lastGetFinancialAccountId = accountId
    lastGetFinancialAccountForceRefresh = forceRefresh
    lastGetFinancialAccountRetrieveBalances = retrieveBalances
  }

  private(set) var getCardDetailsCalled = false
  private(set) var lastCardIdToGetDetails: String?
  override func getCardDetails(accountId: String,
                               callback: @escaping Result<CardDetails, NSError>.Callback) {
    getCardDetailsCalled = true
    lastCardIdToGetDetails = accountId
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
  override func startOauthAuthentication(_ balanceType: AllowedBalanceType,
                                         callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    super.startOauthAuthentication(balanceType, callback: callback)

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

  var nextUpdateUserDataResult: Result<ShiftUser, NSError>?
  override func updateUserData(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    super.updateUserData(userData, callback: callback)

    if let result = nextUpdateUserDataResult {
      callback(result)
    }
  }

  var nextGetFinancialAccountResult: Result<FinancialAccount, NSError>?
  override func getFinancialAccount(accountId: String,
                                    forceRefresh: Bool = true,
                                    retrieveBalances: Bool = false,
                                    callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    super.getFinancialAccount(accountId: accountId,
                              forceRefresh: forceRefresh,
                              retrieveBalances: retrieveBalances,
                              callback: callback)

    if let result = nextGetFinancialAccountResult {
      callback(result)
    }
  }

  var nextGetCardDetailsResult: Result<CardDetails, NSError>?
  override func getCardDetails(accountId: String,
                               callback: @escaping Result<CardDetails, NSError>.Callback) {
    super.getCardDetails(accountId: accountId, callback: callback)

    if let result = nextGetCardDetailsResult {
      callback(result)
    }
  }
}
