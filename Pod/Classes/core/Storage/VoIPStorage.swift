//
// VoIPStorage.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/06/2019.
//

import Foundation

protocol VoIPStorageProtocol {
    func fetchToken(_ apiKey: String, userToken: String, cardId: String, actionSource: VoIPActionSource,
                    callback: @escaping Result<VoIPToken, NSError>.Callback)
}

class VoIPStorage: VoIPStorageProtocol {
    private let transport: JSONTransport

    init(transport: JSONTransport) {
        self.transport = transport
    }

    func fetchToken(_ apiKey: String, userToken: String, cardId: String, actionSource: VoIPActionSource,
                    callback: @escaping Result<VoIPToken, NSError>.Callback)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .voIPAuthorization)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
        let parameters: [String: AnyObject] = [
            "card_id": cardId as AnyObject,
            "action": actionSource.rawValue as AnyObject,
        ]
        transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
            switch result {
            case let .failure(error):
                callback(.failure(error))
            case let .success(json):
                guard let token = json.voIPToken else {
                    callback(.failure(ServiceError(code: .jsonError)))
                    return
                }
                callback(.success(token))
            }
        }
    }
}
