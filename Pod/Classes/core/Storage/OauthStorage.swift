//
//  OauthStorage.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import SwiftyJSON

protocol OauthStorageProtocol {
    func startOauthAuthentication(_ apiKey: String,
                                  userToken: String,
                                  balanceType: AllowedBalanceType,
                                  callback: @escaping Result<OauthAttempt, NSError>.Callback)
    func verifyOauthAttemptStatus(_ apiKey: String,
                                  userToken: String,
                                  attempt: OauthAttempt,
                                  callback: @escaping Result<OauthAttempt, NSError>.Callback)
}

class OauthStorage: OauthStorageProtocol {
    private let transport: JSONTransport

    init(transport: JSONTransport) {
        self.transport = transport
    }

    func startOauthAuthentication(_ apiKey: String,
                                  userToken: String,
                                  balanceType: AllowedBalanceType,
                                  callback: @escaping Result<OauthAttempt, NSError>.Callback)
    {
        let parameters = [
            "provider": balanceType.type as AnyObject,
            "base_uri": balanceType.baseUri as AnyObject,
            "redirect_url": "shift-sdk://oauth-finish" as AnyObject,
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

    func verifyOauthAttemptStatus(_ apiKey: String,
                                  userToken: String,
                                  attempt: OauthAttempt,
                                  callback: @escaping Result<OauthAttempt, NSError>.Callback)
    {
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
