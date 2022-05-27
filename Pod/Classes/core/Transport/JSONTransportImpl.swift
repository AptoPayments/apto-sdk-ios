//
//  JSONTransportImpl.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 11/08/16.
//
//

import Foundation

import Alamofire
import SwiftyJSON

class JSONTransportImpl {
    open var environment: JSONTransportEnvironment
    open var baseUrlProvider: BaseURLProvider

    private let networkManager: NetworkManagerProtocol

    init(environment: JSONTransportEnvironment,
         baseUrlProvider: BaseURLProvider,
         networkManager: NetworkManagerProtocol)
    {
        self.environment = environment
        self.baseUrlProvider = baseUrlProvider
        self.networkManager = networkManager
    }
}

// MARK: - JSONTransportProtocol

extension JSONTransportImpl: JSONTransport {
    public func get(_ url: URLConvertible,
                    authorization: JSONTransportAuthorization,
                    parameters: [String: AnyObject]?,
                    headers: [String: String]? = nil,
                    acceptRedirectTo _: ((String) -> Bool)? = nil,
                    filterInvalidTokenResult: Bool = true,
                    callback: @escaping Swift.Result<JSON, NSError>.Callback)
    {
        var requestHeaders = completeHeaders(authorizationHeader(authorization))
        if let headers = headers {
            requestHeaders += headers
        }
        let request = NetworkRequest(url: url,
                                     method: .get,
                                     parameters: parameters,
                                     body: nil,
                                     headers: requestHeaders,
                                     filterInvalidTokenResult: filterInvalidTokenResult) { result in
            callback(result)
        }
        networkManager.request(request)
    }

    public func post(_ url: URLConvertible,
                     authorization: JSONTransportAuthorization,
                     parameters: [String: AnyObject]?,
                     filterInvalidTokenResult: Bool = true,
                     callback: @escaping Swift.Result<JSON, NSError>.Callback)
    {
        let headers = completeHeaders(authorizationHeader(authorization))
        let request = NetworkRequest(url: url,
                                     method: .post,
                                     parameters: parameters,
                                     body: nil,
                                     headers: headers,
                                     filterInvalidTokenResult: filterInvalidTokenResult,
                                     callback: callback)
        networkManager.request(request)
    }

    func post(_ url: URLConvertible,
              authorization: JSONTransportAuthorization,
              body: String?,
              headers: [String: String]?,
              filterInvalidTokenResult: Bool,
              callback: @escaping Swift.Result<JSON, NSError>.Callback)
    {
        var requestHeaders = completeHeaders(authorizationHeader(authorization))
        if let headers = headers {
            requestHeaders += headers
        }
        let request = NetworkRequest(url: url,
                method: .post,
                parameters: nil,
                body: body,
                headers: requestHeaders,
                filterInvalidTokenResult: filterInvalidTokenResult,
                callback: callback)
        networkManager.request(request)
    }

    public func put(_ url: URLConvertible,
                    authorization: JSONTransportAuthorization,
                    parameters: [String: AnyObject]?,
                    filterInvalidTokenResult: Bool = true,
                    callback: @escaping Swift.Result<JSON, NSError>.Callback)
    {
        let headers = completeHeaders(authorizationHeader(authorization))
        let request = NetworkRequest(url: url,
                                     method: .put,
                                     parameters: parameters,
                                     body: nil,
                                     headers: headers,
                                     filterInvalidTokenResult: filterInvalidTokenResult,
                                     callback: callback)
        networkManager.request(request)
    }

    public func delete(_ url: URLConvertible,
                       authorization: JSONTransportAuthorization,
                       parameters: [String: AnyObject]?,
                       filterInvalidTokenResult: Bool = true,
                       callback: @escaping Swift.Result<Void, NSError>.Callback)
    {
        let headers = completeHeaders(authorizationHeader(authorization))
        let request = NetworkRequest(url: url,
                                     method: .delete,
                                     parameters: parameters,
                                     body: nil,
                                     headers: headers,
                                     filterInvalidTokenResult: filterInvalidTokenResult) { result in
            switch result {
            case let .failure(error):
                callback(.failure(error))
            case .success:
                callback(.success(()))
            }
        }
        networkManager.request(request)
    }

    // MARK: Private Methods

    fileprivate func authorizationHeader(_ authorization: JSONTransportAuthorization) -> [String: String] {
        switch authorization {
        case .none:
            return [String: String]()
        case let .accessToken(projectToken):
            return ["Api-Key": "Bearer " + projectToken]
        case let .accessAndUserToken(projectToken, userToken):
            return ["Api-Key": "Bearer " + projectToken, "Authorization": "Bearer " + userToken]
        }
    }

    fileprivate func completeHeaders(_ headers: [String: String]) -> [String: String] {
        var retVal = headers
        retVal["Content-Type"] = "application/json"
        retVal["Accept"] = "application/json"
        return retVal
    }
}
