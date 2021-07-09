//
//  ApplePayIAPStorage.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 19/4/21.
//

import SwiftyJSON

public protocol ApplePayIAPStorageProtocol {
    func inAppProvisioning(_ apiKey: String,
                           userToken: String,
                           cardId: String,
                           payload: ApplePayIAPInputData,
                           completion: @escaping (ApplePayIAPResult) -> Void)
}

public typealias ApplePayIAPResult = Result<ApplePayIAPIssuerResponse, NSError>

public struct ApplePayIAPStorage: ApplePayIAPStorageProtocol {
    private let transport: JSONTransport
    
    public init(transport: JSONTransport) {
        self.transport = transport
    }
    
    public func inAppProvisioning(_ apiKey: String,
                           userToken: String,
                           cardId: String,
                           payload: ApplePayIAPInputData,
                           completion: @escaping (ApplePayIAPResult) -> Void) {
        let urlParameters = [":account_id": cardId]
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .applePayInAppProvisioning, urlParameters: urlParameters)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                                 userToken: userToken)

        transport.post(url,
                       authorization: auth,
                       parameters: ApplePayIAPInputDataMapper.toJSON(payload),
                       filterInvalidTokenResult: true) { result in
            switch result {
            case .success(let json):
                if let response = json.issuerResponse {
                    completion(.success(response))
                } else {
                    completion(.failure(ServiceError(code: .jsonError)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension JSON {
    var issuerResponse: ApplePayIAPIssuerResponse? {
        guard let epd = self["encrypted_pass_data"].string,
              let ad = self["activation_data"].string,
              let epk = self["ephemeral_public_key"].string else {
            ErrorLogger
                .defaultInstance()
                .log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                         reason: "Can't parse ApplePayIAPIssuerResponse \(self)"))
            return nil
        }
        guard let encryptedPassData = Data(base64Encoded: epd, options: []),
              let activationData = Data(base64Encoded: ad, options: []),
              let ephemeralPublicKey = Data(base64Encoded: epk, options: []) else { return nil }
        return ApplePayIAPIssuerResponse(encryptedPassData: encryptedPassData,
                                         activationData: activationData,
                                         ephemeralPublicKey: ephemeralPublicKey)
    }
}

