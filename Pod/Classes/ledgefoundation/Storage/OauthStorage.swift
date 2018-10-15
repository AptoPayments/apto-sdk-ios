//
//  OauthStorage.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import SwiftyJSON

protocol OauthStorageProtocol {
  func startOauthAuthentication(_ apiKey: String,
                                userToken: String,
                                custodianType: CustodianType,
                                callback: @escaping Result<OauthAttempt, NSError>.Callback)
  func waitForOauthAuthenticationConfirmation(_ apiKey: String,
                                              userToken: String,
                                              attempt: OauthAttempt,
                                              custodianType: CustodianType,
                                              callback: @escaping Result<Custodian, NSError>.Callback)
}

class OauthStorage: OauthStorageProtocol {
  private let transport: JSONTransport

  init(transport: JSONTransport) {
    self.transport = transport
  }

  func startOauthAuthentication(_ apiKey: String,
                                userToken: String,
                                custodianType: CustodianType,
                                callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    let parameters = [
      "provider": custodianType.name() as AnyObject,
      "redirect_url": "shift-sdk://oauth-finish" as AnyObject
    ]
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .startOauth)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<OauthAttempt, NSError> in
        guard let oauthAttempt = json.linkObject as? OauthAttempt else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(oauthAttempt)
      })
    }
  }

  func waitForOauthAuthenticationConfirmation(_ apiKey: String,
                                              userToken: String,
                                              attempt: OauthAttempt,
                                              custodianType: CustodianType,
                                              callback: @escaping Result<Custodian, NSError>.Callback) {
    checkAttemptStatus(apiKey, userToken: userToken, attempt: attempt) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let attempt):
        if attempt.status == .passed {
          guard let credentials = attempt.credentials else {
            callback(.failure(BackendError(code: .incorrectParameters)))
            return
          }
          let custodian = Custodian(custodianType: custodianType, name: custodianType.name())
          custodian.externalCredentials = .oauth(credentials)
          callback(.success(custodian))
        }
        else {
          DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(3000)) {
            self.waitForOauthAuthenticationConfirmation(apiKey,
                                                        userToken: userToken,
                                                        attempt: attempt,
                                                        custodianType: custodianType,
                                                        callback: callback)
          }
        }
      }
    }
  }

  private func checkAttemptStatus(_ apiKey: String,
                                  userToken: String,
                                  attempt: OauthAttempt,
                                  callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    let urlParameters = [":attemptId": attempt.id]
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .oauthStatus, urlParameters: urlParameters)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.get(url,
                  authorization: auth,
                  parameters: nil,
                  headers: nil,
                  acceptRedirectTo: nil,
                  filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<OauthAttempt, NSError> in
        guard let oauthAttempt = json.linkObject as? OauthAttempt else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(oauthAttempt)
      })
    }
  }
}
