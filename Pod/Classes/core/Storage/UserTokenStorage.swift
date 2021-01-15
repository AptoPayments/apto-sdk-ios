//
//  TokenStorage.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 16/03/16.
//

import Foundation

protocol UserTokenStorageProtocol {
  func setCurrent(token: String, withPrimaryCredential: DataPointType, andSecondaryCredential: DataPointType)
  func currentToken() -> String?
  func currentTokenPrimaryCredential() -> DataPointType?
  func currentTokenSecondaryCredential() -> DataPointType?
  func clearCurrentToken()
}

class UserTokenStorage: UserTokenStorageProtocol {
  private let notificationHandler: NotificationHandler
  private let keychain: KeychainProtocol
  fileprivate var currentTokenCache: String?
  fileprivate var currentTokenPrimaryCredentialCache: DataPointType?
  fileprivate var currentTokenSecondaryCredentialCache: DataPointType?

  fileprivate struct Properties {
    static let fileName = "token.txt"
  }

  public init(notificationHandler: NotificationHandler, keychain: KeychainProtocol) {
    self.notificationHandler = notificationHandler
    self.keychain = keychain
    registerToInvalidSessionEvents()
  }

  deinit {
    notificationHandler.removeObserver(self)
  }

  func setCurrent(token: String, withPrimaryCredential: DataPointType, andSecondaryCredential: DataPointType) {
    currentTokenCache = token
    currentTokenPrimaryCredentialCache = withPrimaryCredential
    currentTokenSecondaryCredentialCache = andSecondaryCredential
    persistCurrentToken()
  }

  func currentToken() -> String? {
    if let currentTokenCache = currentTokenCache {
      return currentTokenCache
    }
    loadCurrentToken()
    return currentTokenCache
  }

  func currentTokenPrimaryCredential() -> DataPointType? {
    if let currentTokenPrimaryCredentialCache = currentTokenPrimaryCredentialCache {
      return currentTokenPrimaryCredentialCache
    }
    loadCurrentToken()
    return currentTokenPrimaryCredentialCache
  }

  func currentTokenSecondaryCredential() -> DataPointType? {
    if let currentTokenSecondaryCredentialCache = currentTokenSecondaryCredentialCache {
      return currentTokenSecondaryCredentialCache
    }
    loadCurrentToken()
    return currentTokenSecondaryCredentialCache
  }

  func clearCurrentToken() {
    let localFilePath = self.localFilePath()
    do {
      currentTokenCache = nil
      currentTokenPrimaryCredentialCache = nil
      currentTokenSecondaryCredentialCache = nil
      keychain.removeValue(for: .tokenKey)
      let fileManager = FileManager.default
      try fileManager.removeItem(at: localFilePath)
    }
    catch {}
  }

  private func registerToInvalidSessionEvents() {
    notificationHandler.addObserver(self, selector: #selector(self.didReceiveSessionExpiredEvent),
                                    name: .UserTokenSessionExpiredNotification)
    notificationHandler.addObserver(self, selector: #selector(self.didReceiveSessionInvalidEvent),
                                    name: .UserTokenSessionInvalidNotification)
    notificationHandler.addObserver(self, selector: #selector(self.didReceiveSessionClosedEvent),
                                    name: .UserTokenSessionClosedNotification)
  }

  fileprivate func localFilePath() -> URL {
    let documentDirectory = try! FileManager.default.url(for: .documentDirectory, // swiftlint:disable:this force_try
                                                         in: .userDomainMask,
                                                         appropriateFor: nil,
                                                         create: true)
    let fileURL = documentDirectory.appendingPathComponent(Properties.fileName)
    return fileURL
  }

  fileprivate func readLocalFile() {
    let localFilePath = self.localFilePath()
    if let data = NSKeyedUnarchiver.unarchiveObject(withFile: localFilePath.path) as? [String: String] {
      currentTokenCache = data["user_token"]
      currentTokenPrimaryCredentialCache = DataPointType.from(typeName: data["primary_credential"])
      currentTokenSecondaryCredentialCache = DataPointType.from(typeName: data["secondary_credential"])
    }
    else {
      do {
        let token = try String(contentsOf: localFilePath)
        currentTokenCache = token
        currentTokenPrimaryCredentialCache = .phoneNumber
        currentTokenSecondaryCredentialCache = .email
        persistCurrentToken()
      }
      catch {
        currentTokenCache = nil
        currentTokenPrimaryCredentialCache = nil
        currentTokenSecondaryCredentialCache = nil
      }
    }
  }

  private func loadCurrentToken() {
    loadPersistedToken()
    // If no token persisted in the try to load the token from the old system and migrate it
    if currentTokenCache == nil {
      readLocalFile()
      if currentTokenCache != nil {
        persistCurrentToken()
        removeLegacyTokenFile()
      }
    }
  }

  private func persistCurrentToken() {
    let token = UserTokenWithCredentials(token: currentTokenCache,
                                         primaryCredential: currentTokenPrimaryCredentialCache?.description,
                                         secondaryCredential: currentTokenSecondaryCredentialCache?.description)
    let data = try? JSONEncoder().encode(token)
    keychain.save(value: data, for: .tokenKey)
  }

  private func loadPersistedToken() {
    guard let data = keychain.value(for: .tokenKey),
      let token = try? JSONDecoder().decode(UserTokenWithCredentials.self, from: data) else {
        return
    }
    currentTokenCache = token.token
    currentTokenPrimaryCredentialCache = DataPointType.from(typeName: token.primaryCredential)
    currentTokenSecondaryCredentialCache = DataPointType.from(typeName: token.secondaryCredential)
  }

  private func removeLegacyTokenFile() {
    try? FileManager.default.removeItem(at: localFilePath())
  }

  @objc private func didReceiveSessionExpiredEvent() {
    self.clearCurrentToken()
  }

  @objc private func didReceiveSessionInvalidEvent() {
    self.clearCurrentToken()
  }

  @objc private func didReceiveSessionClosedEvent() {
    self.clearCurrentToken()
  }

}

private extension String {
  static let tokenKey = "com.aptopayments.user.token"
}

public extension Notification.Name {
  static let UserTokenSessionInvalidNotification = Notification.Name("UserTokenSessionInvalidNotification")
  static let UserTokenSessionExpiredNotification = Notification.Name("UserTokenSessionExpiredNotification")
  static let UserTokenSessionClosedNotification = Notification.Name("UserTokenSessionClosedNotification")
}

private struct UserTokenWithCredentials: Codable {
  let token: String?
  let primaryCredential: String?
  let secondaryCredential: String?
}
