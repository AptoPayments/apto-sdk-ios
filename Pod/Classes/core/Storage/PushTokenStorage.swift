//
//  PushTokenStorage.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 24/05/2018.
//

import Foundation

protocol PushTokenStorageProtocol {
    func setCurrent(pushToken: String)
    func currentPushToken() -> String?
    func clearCurrentPushToken()
    func registerPushToken(_ apiKey: String,
                           userToken: String,
                           pushToken: String,
                           callback: @escaping Result<Void, NSError>.Callback)
    func unregisterPushToken(_ apiKey: String,
                             userToken: String,
                             pushToken: String,
                             callback: @escaping Result<Void, NSError>.Callback)
}

class PushTokenStorage: PushTokenStorageProtocol {
    private let transport: JSONTransport
    private var currentPushTokenCache: String?

    init(transport: JSONTransport) {
        self.transport = transport
    }

    func setCurrent(pushToken: String) {
        currentPushTokenCache = pushToken
    }

    func currentPushToken() -> String? {
        return currentPushTokenCache
    }

    func clearCurrentPushToken() {
        currentPushTokenCache = nil
    }

    func registerPushToken(_ apiKey: String,
                           userToken: String,
                           pushToken: String,
                           callback: @escaping Result<Void, NSError>.Callback)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.pushDevice)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
        let data: [String: AnyObject] = [
            "device_type": "ios" as AnyObject,
            "push_token": pushToken as AnyObject,
        ]
        transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
            callback(result.flatMap { _ in
                .success(())
            })
        }
    }

    func unregisterPushToken(_ apiKey: String,
                             userToken _: String,
                             pushToken: String,
                             callback: @escaping Result<Void, NSError>.Callback)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.pushDevice)
        let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
        let data: [String: AnyObject] = [
            "device_type": "ios" as AnyObject,
            "push_token": pushToken as AnyObject,
        ]
        transport.delete(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
            callback(result.flatMap { _ in
                .success(())
            })
        }
    }
}
