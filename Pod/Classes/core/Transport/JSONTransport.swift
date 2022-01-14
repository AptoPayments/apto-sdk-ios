//
//  JSONTransport.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 11/08/16.
//
//

import Alamofire
import Foundation
import SwiftyJSON

public enum JSONTransportAuthorization {
    case none
    case accessToken(projectToken: String)
    case accessAndUserToken(projectToken: String, userToken: String)
}

public enum JSONTransportEnvironment {
    case local
    case staging
    case sandbox
    case live
}

public protocol BaseURLProvider {
    func baseUrl(_ environment: JSONTransportEnvironment) -> String
}

public protocol JSONSerializable {
    func jsonSerialize() -> [String: AnyObject]
}

public protocol JSONTransport {
    // MARK: - Public Attributes

    var environment: JSONTransportEnvironment { get }
    var baseUrlProvider: BaseURLProvider { get }

    // MARK: - Public methods

    func get(_ url: URLConvertible,
             authorization: JSONTransportAuthorization,
             parameters: [String: AnyObject]?,
             headers: [String: String]?,
             acceptRedirectTo: ((String) -> Bool)?,
             filterInvalidTokenResult: Bool,
             callback: @escaping Swift.Result<JSON, NSError>.Callback)

    func post(_ url: URLConvertible,
              authorization: JSONTransportAuthorization,
              parameters: [String: AnyObject]?,
              filterInvalidTokenResult: Bool,
              callback: @escaping Swift.Result<JSON, NSError>.Callback)

    func put(_ url: URLConvertible,
             authorization: JSONTransportAuthorization,
             parameters: [String: AnyObject]?,
             filterInvalidTokenResult: Bool,
             callback: @escaping Swift.Result<JSON, NSError>.Callback)

    func delete(_ url: URLConvertible,
                authorization: JSONTransportAuthorization,
                parameters: [String: AnyObject]?,
                filterInvalidTokenResult: Bool,
                callback: @escaping Swift.Result<Void, NSError>.Callback)
}

extension JSONTransport {
    func baseUrl() -> String {
        return baseUrlProvider.baseUrl(environment)
    }
}
