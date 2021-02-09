//
//  BankAccountStorage.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 18/1/21.
//

import Foundation
import SwiftyJSON

public typealias BankAccountResult = Result<BankAccountDetails, NSError>

protocol BankAccountReadProtocol {
    func loadBankAccount(_ apiKey: String,
                         userToken: String,
                         balanceId: String,
                         completion: @escaping (BankAccountResult) -> Void)
}

protocol BankAccountWriteProtocol {
    func assignBankAccount(_ apiKey: String,
                           userToken: String,
                           balanceId: String,
                           completion: @escaping (BankAccountResult) -> Void)
}

typealias BankAccountStorageProtocol = BankAccountReadProtocol & BankAccountWriteProtocol

public struct BankAccountStorage: BankAccountStorageProtocol {
    private let transport: JSONTransport
    
    public init(transport: JSONTransport) {
        self.transport = transport
    }
    
    public func loadBankAccount(_ apiKey: String,
                                userToken: String,
                                balanceId: String,
                                completion: @escaping (BankAccountResult) -> Void) {
        let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                             url: .bankAccountDetails,
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
                guard let period = json.bankAccountDetails else {
                  completion(.failure(ServiceError(code: .jsonError)))
                  return
                }
                completion(.success(period))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func assignBankAccount(_ apiKey: String,
                                  userToken: String,
                                  balanceId: String,
                                  completion: @escaping (BankAccountResult) -> Void) {
        let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                             url: .bankAccountDetails,
                             urlParameters: [":balance_id": balanceId])
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                                 userToken: userToken)

        transport.post(url,
                       authorization: auth,
                       parameters: nil,
                       filterInvalidTokenResult: true) { result in
            switch result {
            case .success(let json):
                guard let period = json.bankAccountDetails else {
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
    var bankAccountDetails: BankAccountDetails? {
        guard let routingNumber = self["routing_number"].string,
              let accountNumber = self["account_number"].string else {
            ErrorLogger
                .defaultInstance()
                .log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                         reason: "Can't parse BankAccountDetails \(self)"))
            return nil
        }
        return BankAccountDetails(routingNumber: routingNumber, accountNumber: accountNumber)
    }
}
