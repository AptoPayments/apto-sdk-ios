//
//  CardApplicationsStorage.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 20/06/2018.
//
//

protocol CardApplicationsStorageProtocol {
    func createApplication(_ apiKey: String,
                           userToken: String,
                           cardProduct: CardProduct,
                           callback: @escaping Result<CardApplication, NSError>.Callback)
    func applicationStatus(_ apiKey: String,
                           userToken: String,
                           applicationId: String,
                           callback: @escaping Result<CardApplication, NSError>.Callback)
    func setBalanceStore(_ apiKey: String,
                         userToken: String,
                         applicationId: String,
                         custodian: Custodian,
                         callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback)
    func acceptDisclaimer(_ apiKey: String,
                          userToken: String,
                          workflowObject: WorkflowObject,
                          workflowAction: WorkflowAction,
                          callback: @escaping Result<Void, NSError>.Callback)
    func cancelCardApplication(_ apiKey: String,
                               userToken: String,
                               applicationId: String,
                               callback: @escaping Result<Void, NSError>.Callback)
    func issueCard(_ apiKey: String,
                   userToken: String,
                   applicationId: String,
                   metadata: String?,
                   design: IssueCardDesign?,
                   callback: @escaping Result<Card, NSError>.Callback)
}

class CardApplicationsStorage: CardApplicationsStorageProtocol {
    private let transport: JSONTransport

    init(transport: JSONTransport) {
        self.transport = transport
    }

    func createApplication(_ apiKey: String,
                           userToken: String,
                           cardProduct: CardProduct,
                           callback: @escaping Result<CardApplication, NSError>.Callback)
    {
        let parameters = ["card_product_id": cardProduct.id as AnyObject]
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .applyToCard)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                                 userToken: userToken)
        transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
            callback(result.flatMap { json -> Result<CardApplication, NSError> in
                guard let application = json.linkObject as? CardApplication else {
                    return .failure(ServiceError(code: .jsonError))
                }
                return .success(application)
            })
        }
    }

    func applicationStatus(_ apiKey: String,
                           userToken: String,
                           applicationId: String,
                           callback: @escaping Result<CardApplication, NSError>.Callback)
    {
        let urlParameters: [String: String] = [
            ":applicationId": applicationId,
        ]
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(),
                             url: JSONRouter.cardApplicationStatus,
                             urlParameters: urlParameters)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                                 userToken: userToken)
        transport.get(url,
                      authorization: auth,
                      parameters: nil,
                      headers: nil,
                      acceptRedirectTo: nil,
                      filterInvalidTokenResult: true) { result in
            callback(result.flatMap { json -> Result<CardApplication, NSError> in
                guard let application = json.linkObject as? CardApplication else {
                    return .failure(ServiceError(code: .jsonError))
                }
                return .success(application)
            })
        }
    }

    func setBalanceStore(_ apiKey: String,
                         userToken: String,
                         applicationId: String,
                         custodian: Custodian,
                         callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback)
    {
        guard let credentials = custodian.externalCredentials, case let .oauth(oauthCredentials) = credentials else {
            callback(.failure(BackendError(code: .incorrectParameters)))
            return
        }
        let urlParameters: [String: String] = [
            ":applicationId": applicationId,
        ]
        let parameters = [
            "oauth_token_id": oauthCredentials.oauthTokenId as AnyObject,
        ]
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.setBalanceStore,
                             urlParameters: urlParameters)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
        transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
            callback(result.flatMap { json -> Result<SelectBalanceStoreResult, NSError> in
                guard let result = json.selectBalanceStoreResult else {
                    return .failure(ServiceError(code: .jsonError))
                }
                return .success(result)
            })
        }
    }

    func acceptDisclaimer(_ apiKey: String,
                          userToken: String,
                          workflowObject: WorkflowObject,
                          workflowAction: WorkflowAction,
                          callback: @escaping Result<Void, NSError>.Callback)
    {
        let parameters = [
            "workflow_object_id": workflowObject.workflowObjectId as AnyObject,
            "action_id": workflowAction.actionId as AnyObject,
        ]
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.acceptDisclaimer)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                                 userToken: userToken)
        transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
            callback(result.flatMap { json -> Result<Void, NSError> in
                if let error = json.linkObject as? NSError {
                    return .failure(error)
                } else {
                    return .success(())
                }
            })
        }
    }

    func cancelCardApplication(_ apiKey: String,
                               userToken: String,
                               applicationId: String,
                               callback: @escaping Result<Void, NSError>.Callback)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(),
                             url: JSONRouter.cardApplication,
                             urlParameters: [":applicationId": applicationId])
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
        transport.delete(url, authorization: auth, parameters: nil, filterInvalidTokenResult: true, callback: callback)
    }

    func issueCard(_ apiKey: String,
                   userToken: String,
                   applicationId: String,
                   metadata: String? = nil,
                   design: IssueCardDesign? = nil,
                   callback: @escaping Result<Card, NSError>.Callback)
    {
        var parameters = [
            "application_id": applicationId as AnyObject,
        ]
        if let metadata = metadata {
            parameters["metadata"] = metadata as AnyObject
        }
        if let design = design {
            parameters["design"] = IssueCardDesignRequestMapper.map(from: design).toJSON() as AnyObject
        }
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.issueCard)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
        transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
            switch result {
            case let .failure(error):
                callback(.failure(error))
            case let .success(json):
                guard let application = json.linkObject as? Card else {
                    return callback(.failure(ServiceError(code: .jsonError)))
                }
                callback(.success(application))
            }
        }
    }
}
