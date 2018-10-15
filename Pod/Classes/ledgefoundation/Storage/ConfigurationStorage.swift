//
//  ConfigurationStorage.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 02/06/16.
//
//

import Foundation
import SwiftyJSON

protocol ConfigurationStorageProtocol {
  var contextConfigurationCache: ContextConfiguration? { get }
  var linkConfigurationCache: LinkConfiguration? { get }
  var bankOauthConfigurationCache: BankOauthConfiguration? { get }
  var cardConfigurationCache: ShiftCardConfiguration? { get }
  var shiftCardOptions: ShiftCardOptions { get }

  func contextConfiguration(_ apiKey: String,
                            forceRefresh: Bool,
                            callback: @escaping Result<ContextConfiguration, NSError>.Callback)
  func linkConfiguration(_ apiKey: String,
                         forceRefresh: Bool,
                         callback: @escaping Result<LinkConfiguration, NSError>.Callback)
  func bankOauthConfiguration(_ apiKey: String,
                              userToken: String,
                              forceRefresh: Bool,
                              callback: @escaping Result<BankOauthConfiguration, NSError>.Callback)
  func cardConfiguration(_ apiKey: String,
                         forceRefresh: Bool,
                         callback: @escaping Result<ShiftCardConfiguration, NSError>.Callback)
  func setShiftCardOptions(shiftCardOptions: ShiftCardOptions)
}

extension ConfigurationStorageProtocol {
  func contextConfiguration(_ apiKey: String,
                            forceRefresh: Bool = false,
                            callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    contextConfiguration(apiKey, forceRefresh: forceRefresh, callback: callback)
  }

  func linkConfiguration(_ apiKey: String,
                         forceRefresh: Bool = false,
                         callback: @escaping Result<LinkConfiguration, NSError>.Callback) {
    linkConfiguration(apiKey, forceRefresh: forceRefresh, callback: callback)
  }

  func bankOauthConfiguration(_ apiKey: String,
                              userToken: String,
                              forceRefresh: Bool = false,
                              callback: @escaping Result<BankOauthConfiguration, NSError>.Callback) {
    bankOauthConfiguration(apiKey, userToken: userToken, forceRefresh: forceRefresh, callback: callback)
  }

  func cardConfiguration(_ apiKey: String,
                         forceRefresh: Bool = false,
                         callback: @escaping Result<ShiftCardConfiguration, NSError>.Callback) {
    cardConfiguration(apiKey, forceRefresh: forceRefresh, callback: callback)
  }
}

class ConfigurationStorage: ConfigurationStorageProtocol {
  private let transport: JSONTransport
  private(set) var contextConfigurationCache: ContextConfiguration?
  private(set) var linkConfigurationCache: LinkConfiguration?
  private(set) var bankOauthConfigurationCache: BankOauthConfiguration?
  private(set) var cardConfigurationCache: ShiftCardConfiguration?
  private(set) var shiftCardOptions = ShiftCardOptions()

  init(transport: JSONTransport) {
    self.transport = transport
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
                    filterInvalidTokenResult: true) { result in
        switch result {
        case .failure(let error):
          callback(.failure(error))
          return
        case .success:
          callback(result.flatMap { json -> Result<ContextConfiguration, NSError> in
            guard let contextConfiguration = json.linkObject as? ContextConfiguration else {
              return .failure(ServiceError(code: .jsonError))
            }
            self.contextConfigurationCache = contextConfiguration
            return .success(contextConfiguration)
          })
        }
      }
    }
    else {
      callback(.success(contextConfigurationCache!)) // swiftlint:disable:this force_unwrapping
    }
  }

  func linkConfiguration(_ apiKey: String,
                         forceRefresh: Bool = false,
                         callback: @escaping Result<LinkConfiguration, NSError>.Callback) {
    if linkConfigurationCache == nil || forceRefresh {
      let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.linkConfig)
      let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
      transport.get(url,
                    authorization: auth,
                    parameters: nil,
                    headers: nil,
                    acceptRedirectTo: nil,
                    filterInvalidTokenResult: true) { result in
        switch result {
        case .failure(let error):
          callback(.failure(error))
          return
        case .success:
          callback(result.flatMap { json -> Result<LinkConfiguration, NSError> in
            guard let linkConfiguration = json.linkObject as? LinkConfiguration else {
              return .failure(ServiceError(code: .jsonError))
            }
            self.linkConfigurationCache = linkConfiguration
            return .success(linkConfiguration)
          })
        }
      }
    }
    else {
      callback(.success(linkConfigurationCache!)) // swiftlint:disable:this force_unwrapping
    }
  }

  func bankOauthConfiguration(_ apiKey: String,
                              userToken: String,
                              forceRefresh: Bool = false,
                              callback: @escaping Result<BankOauthConfiguration, NSError>.Callback) {
    if bankOauthConfigurationCache == nil || forceRefresh {
      let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.bankOauthConfig)
      let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
      transport.get(url,
                    authorization: auth,
                    parameters: nil,
                    headers: ["Accept": "application/json"],
                    acceptRedirectTo: nil,
                    filterInvalidTokenResult: true) { result in
        switch result {
        case .failure(let error):
          callback(.failure(error))
          return
        case .success:
          callback(result.flatMap { json -> Result<BankOauthConfiguration, NSError> in
            guard let bankOauthConfiguration = json.linkObject as? BankOauthConfiguration else {
              return .failure(ServiceError(code: .jsonError))
            }
            self.bankOauthConfigurationCache = bankOauthConfiguration
            return .success(bankOauthConfiguration)
          })
        }
      }
    }
    else {
      callback(.success(bankOauthConfigurationCache!)) // swiftlint:disable:this force_unwrapping
    }
  }

  func cardConfiguration(_ apiKey: String,
                         forceRefresh: Bool = false,
                         callback: @escaping Result<ShiftCardConfiguration, NSError>.Callback) {
    if cardConfigurationCache == nil || forceRefresh {
      let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.cardConfig)
      let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
      transport.get(url,
                    authorization: auth,
                    parameters: nil,
                    headers: nil,
                    acceptRedirectTo: nil,
                    filterInvalidTokenResult: true) { result in
        switch result {
        case .failure(let error):
          callback(.failure(error))
          return
        case .success:
          callback(result.flatMap { json -> Result<ShiftCardConfiguration, NSError> in
            guard let cardConfiguration = json.linkObject as? ShiftCardConfiguration else {
              return .failure(ServiceError(code: .jsonError))
            }

            // Store locally defined options in the same configuration object
            cardConfiguration.features = self.shiftCardOptions.features

            self.cardConfigurationCache = cardConfiguration
            return .success(cardConfiguration)
          })
        }
      }
    }
    else {
      callback(.success(cardConfigurationCache!)) // swiftlint:disable:this force_unwrapping
    }
  }

  func setShiftCardOptions(shiftCardOptions: ShiftCardOptions) {
    for featureKey in shiftCardOptions.features.keys {
      self.shiftCardOptions.features[featureKey] = shiftCardOptions.features[featureKey]
    }
  }
}
