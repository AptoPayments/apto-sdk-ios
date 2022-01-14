//
//  P2PTransferStorage.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 18/7/21.
//

import Foundation
import SwiftyJSON

public typealias P2PTransferRecipientResult = Result<CardholderData, NSError>
public typealias P2PInviteResult = Result<Void, NSError>
public typealias P2PTransferResult = Result<P2PTransferResponse, NSError>

public protocol P2PTransferProtocol {
    func getRecipient(_ apiKey: String,
                      userToken: String,
                      phoneCode: String?, phoneNumber: String?,
                      email: String?,
                      completion: @escaping (P2PTransferRecipientResult) -> Void)

    func transfer(_ apiKey: String,
                  userToken: String,
                  transferRequest: P2PTransferRequest,
                  completion: @escaping (P2PTransferResult) -> Void)
}

public struct P2PTransferStorage: P2PTransferProtocol {
    private let transport: JSONTransport

    public init(transport: JSONTransport) {
        self.transport = transport
    }

    public func getRecipient(_ apiKey: String,
                             userToken: String,
                             phoneCode: String?,
                             phoneNumber: String?,
                             email: String?,
                             completion: @escaping (P2PTransferRecipientResult) -> Void)
    {
        guard validContactData(phoneCode: phoneCode,
                               phoneNumber: phoneNumber, email: email)
        else {
            completion(.failure(ServiceError(code: .invalidRequestData)))
            return
        }
        var urlParameters = [String: String]()
        if let email = email {
            urlParameters["email"] = email
        } else if let countryCode = phoneCode,
                  let number = phoneNumber
        {
            urlParameters["phone_country_code"] = countryCode
            urlParameters["phone_number"] = number
        }

        let url = URLWrapper(baseUrl: transport.environment.baseUrl(),
                             url: .p2pRecipient,
                             urlParameters: urlParameters)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                                 userToken: userToken)

        transport.get(url,
                      authorization: auth,
                      parameters: nil,
                      headers: nil,
                      acceptRedirectTo: nil,
                      filterInvalidTokenResult: true) { result in
            switch result {
            case let .success(json):
                guard let cardholderData = json.cardholderData else {
                    completion(.failure(ServiceError(code: .jsonError)))
                    return
                }
                completion(.success(cardholderData))

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func transfer(_ apiKey: String,
                         userToken: String,
                         transferRequest: P2PTransferRequest,
                         completion: @escaping (P2PTransferResult) -> Void)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .p2pTransfer)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                                 userToken: userToken)

        transport.post(url,
                       authorization: auth,
                       parameters: transferRequest.toJSON(),
                       filterInvalidTokenResult: true) { result in
            switch result {
            case let .success(json):
                guard let transferResult = json.p2pTransferResponse else {
                    completion(.failure(ServiceError(code: .jsonError)))
                    return
                }
                completion(.success(transferResult))

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Private methods

    private func validContactData(phoneCode: String?,
                                  phoneNumber: String?,
                                  email: String?) -> Bool
    {
        (phoneCode != nil && phoneNumber != nil) || email != nil
    }
}

extension JSON {
    var cardholderData: CardholderData? {
        guard let firstName = self["name"]["first_name"].string,
              let lastName = self["name"]["last_name"].string,
              let cardholderId = self["cardholder_id"].string
        else {
            ErrorLogger
                .defaultInstance()
                .log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                         reason: "Can't parse Cardholder data \(self)"))
            return nil
        }
        return CardholderData(firstName: firstName, lastName: lastName, cardholderId: cardholderId)
    }

    var p2pTransferResponse: P2PTransferResponse? {
        guard let transferId = self["id"].string,
              let statusValue = self["status"].string, let status = PaymentResultStatus(rawValue: statusValue),
              let originalBalanceId = self["source_id"].string,
              let amount = self["amount"].amount,
              let firstName = self["recipient"]["name"]["first_name"].string,
              let lastName = self["recipient"]["name"]["last_name"].string
        else {
            ErrorLogger
                .defaultInstance()
                .log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                         reason: "Can't parse p2p transfer response data \(self)"))
            return nil
        }

        var createdAt: Date?
        if let date = self["created_at"].string,
           let createdAtValue = Date.timeFromISO8601(date)
        {
            createdAt = createdAtValue
        } else if let date = self["created_at"].string,
                  let parsed = Date.parse(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSZ", dateValue: date)
        {
            createdAt = parsed
        }

        return P2PTransferResponse(transferId: transferId,
                                   status: status,
                                   sourceId: originalBalanceId,
                                   amount: amount,
                                   recipientFirstName: firstName,
                                   recipientLastName: lastName, createdAt: createdAt)
    }
}

extension P2PInvite {
    func toJSON() -> [String: AnyObject] {
        [
            "phone": [
                "country_code": (countryCode ?? "") as AnyObject,
                "phone_number": (phoneNumber ?? "") as AnyObject,
            ],
            "email": (email ?? "") as AnyObject,
        ] as [String: AnyObject]
    }
}

extension P2PTransferRequest {
    func toJSON() -> [String: AnyObject] {
        [
            "source_id": sourceId as AnyObject,
            "recipient_id": recipientId as AnyObject,
            "amount": [
                "currency": amount.currency.value as AnyObject,
                "amount": amount.amount.value as AnyObject,
            ],
        ] as [String: AnyObject]
    }
}
