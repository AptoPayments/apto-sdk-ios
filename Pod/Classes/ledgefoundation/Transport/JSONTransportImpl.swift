//
//  JSONTransportImpl.swift
//  Pods
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
       networkManager: NetworkManagerProtocol) {
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
                  acceptRedirectTo: ((String) -> Bool)? = nil,
                  filterInvalidTokenResult: Bool = true,
                  callback: @escaping Result<JSON, NSError>.Callback) {
    networkManager.delegate.taskWillPerformHTTPRedirection = { (session: URLSession!,
                                                                task: URLSessionTask!,
                                                                response: HTTPURLResponse!,
                                                                request: URLRequest!) in
      guard let function = acceptRedirectTo,
            let _ = request.url else {
        return request
      }
      if function("") == true {
        return request
      }
      else {
        return nil
      }
    }
    var requestHeaders = self.completeHeaders(self.authorizationHeader(authorization))
    if let headers = headers {
      requestHeaders += headers
    }
    let request = NetworkRequest(url: url,
                                 method: .get,
                                 parameters: parameters,
                                 headers: requestHeaders,
                                 filterInvalidTokenResult: filterInvalidTokenResult) { result in
      self.networkManager.delegate.taskWillPerformHTTPRedirection = nil
      callback(result)
    }
    networkManager.request(request)
  }

  public func post(_ url: URLConvertible,
                   authorization: JSONTransportAuthorization,
                   parameters: [String: AnyObject]?,
                   filterInvalidTokenResult: Bool = true,
                   callback: @escaping Result<JSON, NSError>.Callback) {
    let headers = self.completeHeaders(self.authorizationHeader(authorization))
    let request = NetworkRequest(url: url,
                                 method: .post,
                                 parameters: parameters,
                                 headers: headers,
                                 filterInvalidTokenResult: filterInvalidTokenResult,
                                 callback: callback)
    networkManager.request(request)
  }

  public func put(_ url: URLConvertible,
                  authorization: JSONTransportAuthorization,
                  parameters: [String: AnyObject]?,
                  filterInvalidTokenResult: Bool = true,
                  callback: @escaping Result<JSON, NSError>.Callback) {
    let headers = self.completeHeaders(self.authorizationHeader(authorization))
    let request = NetworkRequest(url: url,
                                 method: .put,
                                 parameters: parameters,
                                 headers: headers,
                                 filterInvalidTokenResult: filterInvalidTokenResult,
                                 callback: callback)
    networkManager.request(request)
  }

  public func delete(_ url: URLConvertible,
                     authorization: JSONTransportAuthorization,
                     parameters: [String: AnyObject]?,
                     filterInvalidTokenResult: Bool = true,
                     callback: @escaping Result<Void, NSError>.Callback) {
    let headers = self.completeHeaders(authorizationHeader(authorization))
    let request = NetworkRequest(url: url,
                                 method: .delete,
                                 parameters: parameters,
                                 headers: headers,
                                 filterInvalidTokenResult: filterInvalidTokenResult) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(_):
        callback(.success(Void()))
      }
    }
    networkManager.request(request)
  }

  // MARK: Private Methods

  fileprivate func authorizationHeader(_ authorization: JSONTransportAuthorization) -> [String: String] {
    switch authorization {
    case .none:
      return [String: String]()
    case .accessToken(let token, let projectToken):
      return ["Developer-Authorization": "Bearer " + token, "Project": "Bearer " + projectToken]
    case .accessAndUserToken(let token, let projectToken, let userToken):
      return ["Developer-Authorization": "Bearer " + token,
              "Project": "Bearer " + projectToken,
              "Authorization": "Bearer " + userToken]
    }
  }

  fileprivate func completeHeaders(_ headers: [String: String]) -> [String: String] {
    var retVal = headers
    retVal["Content-Type"] = "application/json"
    retVal["Accept"] = "application/json"
    return retVal
  }
}
