//
//  ConfigurationStorage.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 02/06/16.
//
//

import Foundation

protocol ConfigurationStorageProtocol {
  var contextConfigurationCache: ContextConfiguration? { get }
  var cardOptions: CardOptions? {get set}

  func contextConfiguration(_ apiKey: String,
                            forceRefresh: Bool,
                            callback: @escaping Result<ContextConfiguration, NSError>.Callback)
  func cardConfiguration(_ apiKey: String,
                         userToken: String,
                         forceRefresh: Bool,
                         cardProductId: String,
                         callback: @escaping Result<CardConfiguration, NSError>.Callback)
  func cardProducts(_ apiKey: String, userToken: String,
                    callback: @escaping Result<[CardProductSummary], NSError>.Callback)
  func uiConfig() -> UIConfig?
}

extension ConfigurationStorageProtocol {
  func contextConfiguration(_ apiKey: String,
                            forceRefresh: Bool = false,
                            callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    contextConfiguration(apiKey, forceRefresh: forceRefresh, callback: callback)
  }

  func cardConfiguration(_ apiKey: String,
                         userToken: String,
                         forceRefresh: Bool = false,
                         cardProductId: String,
                         callback: @escaping Result<CardConfiguration, NSError>.Callback) {
    cardConfiguration(apiKey, userToken: userToken, forceRefresh: forceRefresh, cardProductId: cardProductId,
                      callback: callback)
  }

  func cardProducts(_ apiKey: String, userToken: String,
                    callback: @escaping Result<[CardProductSummary], NSError>.Callback) {
    cardProducts(apiKey, userToken: userToken, callback: callback)
  }
}

class ConfigurationStorage: ConfigurationStorageProtocol {
  private let transport: JSONTransport
  private(set) var contextConfigurationCache: ContextConfiguration?
  private var cardConfigurationCache: [String: CardConfiguration] = [:]
  private let cache: ProjectBrandingCacheProtocol
  var cardOptions: CardOptions?

  init(transport: JSONTransport, cache: ProjectBrandingCacheProtocol) {
    self.transport = transport
    self.cache = cache
  }

  func contextConfiguration(_ apiKey: String,
                            forceRefresh: Bool = false,
                            callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    if contextConfigurationCache == nil || forceRefresh {
      let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.contextConfig)
      let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
      transport.get(url,
                    authorization: auth,
                    parameters: nil,
                    headers: nil,
                    acceptRedirectTo: nil,
                    filterInvalidTokenResult: true) { [weak self] result in
        switch result {
        case .failure(let error):
          callback(.failure(error))
          return
        case .success:
          callback(result.flatMap { json -> Result<ContextConfiguration, NSError> in
            guard let contextConfiguration = json.linkObject as? ContextConfiguration else {
              return .failure(ServiceError(code: .jsonError))
            }
            self?.contextConfigurationCache = contextConfiguration
            self?.cache.saveProjectBranding(contextConfiguration.projectConfiguration.branding)
            return .success(contextConfiguration)
          })
        }
      }
    }
    else {
      callback(.success(contextConfigurationCache!)) // swiftlint:disable:this force_unwrapping
    }
  }

  func cardConfiguration(_ apiKey: String,
                         userToken: String,
                         forceRefresh: Bool = false,
                         cardProductId: String,
                         callback: @escaping Result<CardConfiguration, NSError>.Callback) {
    if let cardConfiguration = cardConfigurationCache[cardProductId], forceRefresh == false {
      return callback(.success(cardConfiguration))
    }
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.cardProduct,
                         urlParameters: [":cardProductId": cardProductId])
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.get(url, authorization: auth, parameters: nil, headers: nil, acceptRedirectTo: nil,
                  filterInvalidTokenResult: true) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        callback(.failure(error))
        return
      case .success:
        callback(result.flatMap { json -> Result<CardConfiguration, NSError> in
          guard let cardConfiguration = json.linkObject as? CardConfiguration else {
            return .failure(ServiceError(code: .jsonError))
          }

          self.cardConfigurationCache[cardProductId] = cardConfiguration
          return .success(cardConfiguration)
        })
      }
    }
  }

  func cardProducts(_ apiKey: String, userToken: String,
                    callback: @escaping Result<[CardProductSummary], NSError>.Callback) {
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .cardProducts)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.get(url, authorization: auth, parameters: nil, headers: nil, acceptRedirectTo: nil,
                  filterInvalidTokenResult: true) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success:
        callback(result.flatMap { json -> Result<[CardProductSummary], NSError> in
          guard let cardProducts = json.linkObject as? [CardProductSummary] else {
            return .failure(ServiceError(code: .jsonError))
          }
          return .success(cardProducts)
        })
      }
    }
  }

  func uiConfig() -> UIConfig? {
    guard let projectBranding = cache.cachedProjectBranding() else {
      return nil
    }
    return UIConfig(projectBranding: projectBranding, fontCustomizationOptions: cardOptions?.fontCustomizationOptions)
  }
}
