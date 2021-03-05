//
//  ACHAccountStorage.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 18/1/21.
//

import Foundation
import SwiftyJSON

public typealias ACHAccountResult = Result<ACHAccountDetails, NSError>

protocol ACHAccountReadProtocol {
    func loadACHAccount(_ apiKey: String,
                         userToken: String,
                         balanceId: String,
                         completion: @escaping (ACHAccountResult) -> Void)
}

protocol ACHAccountWriteProtocol {
    func assignACHAccount(_ apiKey: String,
                           userToken: String,
                           balanceId: String,
                           completion: @escaping (ACHAccountResult) -> Void)
}

typealias ACHAccountStorageProtocol = ACHAccountReadProtocol & ACHAccountWriteProtocol

public struct ACHAccountStorage: ACHAccountStorageProtocol {
    private let transport: JSONTransport
    
    public init(transport: JSONTransport) {
        self.transport = transport
    }
    
    public func loadACHAccount(_ apiKey: String,
                                userToken: String,
                                balanceId: String,
                                completion: @escaping (ACHAccountResult) -> Void) {
        let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                             url: .achAccountDetails,
                             urlParameters: [":balance_id": balanceId])
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                                 userToken: userToken)

        transport.get(url,
                      authorization: auth,
                      parameters: nil,
                      headers: nil,
                      acceptRedirectTo: nil,
                      filterInvalidTokenResult: true) { result in
            switch result {
            case .success(let json):
                guard let period = json["account_details"].achAccountDetails else {
                  completion(.failure(ServiceError(code: .jsonError)))
                  return
                }
                completion(.success(period))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func assignACHAccount(_ apiKey: String,
                                  userToken: String,
                                  balanceId: String,
                                  completion: @escaping (ACHAccountResult) -> Void) {
        let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                             url: .achAccountDetails,
                             urlParameters: [":balance_id": balanceId])
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                                 userToken: userToken)

        transport.post(url,
                       authorization: auth,
                       parameters: nil,
                       filterInvalidTokenResult: true) { result in
            switch result {
            case .success(let json):
                guard let period = json["account_details"].achAccountDetails else {
                  completion(.failure(ServiceError(code: .jsonError)))
                  return
                }
                completion(.success(period))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension JSON {
    var achAccountDetails: ACHAccountDetails? {
        guard let routingNumber = self["routing_number"].string,
              let accountNumber = self["account_number"].string else {
            ErrorLogger
                .defaultInstance()
                .log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                         reason: "Can't parse ACHAccountDetails \(self)"))
            return nil
        }
        return ACHAccountDetails(routingNumber: routingNumber, accountNumber: accountNumber)
    }
}
