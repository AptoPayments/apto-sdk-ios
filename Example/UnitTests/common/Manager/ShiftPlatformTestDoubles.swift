//
//  ShiftPlatformTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 20/08/2018.
//
//

@testable import ShiftSDK

class ShiftPlatformSpy: ShiftPlatform {
  private(set) var currentTokenCalled = false
  var nextAccessToken: AccessToken? = AccessToken(token: "Token",
                                                  primaryCredential: .phoneNumber,
                                                  secondaryCredential: .birthDate)
  override func currentToken() -> AccessToken? {
    currentTokenCalled = true
    return nextAccessToken
  }

  private(set) var currentUserInfoCalled = false
  override func currentUserInfo(_ accessToken: AccessToken,
                                filterInvalidTokenResult: Bool = true,
                                callback: @escaping Result<ShiftUser, NSError>.Callback) {
    currentUserInfoCalled = true
  }

  private(set) var clearUserTokenCalled = false
  override func clearUserToken() {
    clearUserTokenCalled = true
  }

  func resetSpies() {
    currentTokenCalled = false
    currentUserInfoCalled = false
    clearUserTokenCalled = false
  }
}

class ShiftPlatformFake: ShiftPlatformSpy {
  var currentUserInfoNextResult: Result<ShiftUser, NSError>?
  override func currentUserInfo(_ accessToken: AccessToken,
                                filterInvalidTokenResult: Bool = true,
                                callback: @escaping Result<ShiftUser, NSError>.Callback) {
    super.currentUserInfo(accessToken, filterInvalidTokenResult: filterInvalidTokenResult, callback: callback)

    guard let result = currentUserInfoNextResult else {
      return
    }
    callback(result)
  }
}
