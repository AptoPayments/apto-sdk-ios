//
// NotificationPreferencesStorage.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 07/03/2019.
//

import Foundation

protocol NotificationPreferencesStorageProtocol {
  func fetchPreferences(_ apiKey: String,
                        userToken: String,
                        callback: @escaping Result<NotificationPreferences, NSError>.Callback)
  func updatePreferences(_ apiKey: String,
                         userToken: String,
                         preferences: NotificationPreferences,
                         callback: @escaping Result<NotificationPreferences, NSError>.Callback)
}

class NotificationPreferencesStorage: NotificationPreferencesStorageProtocol {
  private let transport: JSONTransport

  init(transport: JSONTransport) {
    self.transport = transport
  }

  func fetchPreferences(_ apiKey: String,
                        userToken: String,
                        callback: @escaping Result<NotificationPreferences, NSError>.Callback) {
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .notificationPreferences)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.get(url, authorization: auth, parameters: nil, headers: nil, acceptRedirectTo: nil,
                  filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<NotificationPreferences, NSError> in
        guard let preferences = json.notificationPreferences else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(preferences)
      })
    }
  }

  func updatePreferences(_ apiKey: String,
                         userToken: String,
                         preferences: NotificationPreferences,
                         callback: @escaping Result<NotificationPreferences, NSError>.Callback) {
    let parameters = preferences.jsonSerialize()
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .notificationPreferences)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.put(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success:
        callback(result.flatMap { json -> Result<NotificationPreferences, NSError> in
          guard let preferences = json.notificationPreferences else {
            return .failure(ServiceError(code: .jsonError))
          }
          return .success(preferences)
        })
      }
    }
  }
}
