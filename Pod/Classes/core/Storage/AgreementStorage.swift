//
//  AgreementStorage.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 22/1/21.
//

import Foundation
import SwiftyJSON

public typealias RecordedAgreementsResult = Result<[AgreementDetail], NSError>

protocol AgreementStorageProtocol {
    func recordAgreement(_ apiKey: String,
                         userToken: String,
                         agreementRequest: AgreementRequest,
                         completion: @escaping (RecordedAgreementsResult) -> Void)
}

public struct AgreementStorage: AgreementStorageProtocol {
    private let transport: JSONTransport

    public init(transport: JSONTransport) {
        self.transport = transport
    }

    public func recordAgreement(_ apiKey: String,
                                userToken: String,
                                agreementRequest: AgreementRequest,
                                completion: @escaping (RecordedAgreementsResult) -> Void)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .recordAgreementAction)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                                 userToken: userToken)

        transport.post(url,
                       authorization: auth,
                       parameters: agreementRequest.toJSON(),
                       filterInvalidTokenResult: true) { result in
            switch result {
            case let .success(json):
                guard let agreements = json.userAgreements, !agreements.isEmpty else {
                    completion(.failure(ServiceError(code: .jsonError)))
                    return
                }
                completion(.success(agreements))

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension JSON {
    var userAgreements: [AgreementDetail]? {
        let agreements = self["user_agreements"].arrayValue
        return agreements.compactMap { $0.userAgreement() }
    }

    func userAgreement(with key: String = "user_agreement") -> AgreementDetail? {
        guard let source = self[key].dictionary,
              let idStr = source["id"]?.string,
              let agreementKey = source["agreement_key"]?.string,
              let action = source["action"]?.string, let userAction = UserActionType(rawValue: action),
              let actionRecorded = source["recorded_at"]?.string,
              let recordedAt = Date.dateFromISO8601(string: actionRecorded)
        else {
            ErrorLogger
                .defaultInstance()
                .log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                         reason: "Can't parse AgreementDetail \(self)"))
            return nil
        }
        return AgreementDetail(idStr: idStr,
                               agreementKey: agreementKey,
                               userAction: userAction,
                               actionRecordedAt: recordedAt)
    }
}
