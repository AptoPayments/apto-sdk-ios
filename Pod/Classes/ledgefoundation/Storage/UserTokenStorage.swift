//
//  TokenStorage.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 16/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
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
  fileprivate var currentTokenCache: String?
  fileprivate var currentTokenPrimaryCredentialCache: DataPointType?
  fileprivate var currentTokenSecondaryCredentialCache: DataPointType?

  fileprivate struct Properties {
    static let fileName = "token.txt"
  }

  func setCurrent(token: String, withPrimaryCredential: DataPointType, andSecondaryCredential: DataPointType) {
    currentTokenCache = token
    currentTokenPrimaryCredentialCache = withPrimaryCredential
    currentTokenSecondaryCredentialCache = andSecondaryCredential
    self.writeLocalFile()
  }

  func currentToken() -> String? {
    if let currentTokenCache = currentTokenCache {
      return currentTokenCache
    }
    readLocalFile()
    return currentTokenCache
  }

  func currentTokenPrimaryCredential() -> DataPointType? {
    if let currentTokenPrimaryCredentialCache = currentTokenPrimaryCredentialCache {
      return currentTokenPrimaryCredentialCache
    }
    readLocalFile()
    return currentTokenPrimaryCredentialCache
  }

  func currentTokenSecondaryCredential() -> DataPointType? {
    if let currentTokenSecondaryCredentialCache = currentTokenSecondaryCredentialCache {
      return currentTokenSecondaryCredentialCache
    }
    readLocalFile()
    return currentTokenSecondaryCredentialCache
  }

  func clearCurrentToken() {
    let localFilePath = self.localFilePath()
    do {
      currentTokenCache = nil
      currentTokenPrimaryCredentialCache = nil
      currentTokenSecondaryCredentialCache = nil
      let fileManager = FileManager.default
      try fileManager.removeItem(at: localFilePath)
    }
    catch {}
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
        writeLocalFile()
      }
      catch {
        currentTokenCache = nil
        currentTokenPrimaryCredentialCache = nil
        currentTokenSecondaryCredentialCache = nil
      }
    }
  }

  fileprivate func writeLocalFile() {
    let localFilePath = self.localFilePath()
    let data = [
      "user_token": currentTokenCache,
      "primary_credential": currentTokenPrimaryCredentialCache?.description,
      "secondary_credential": currentTokenSecondaryCredentialCache?.description
    ]
    NSKeyedArchiver.archiveRootObject(data, toFile: localFilePath.path)
  }
}

extension Notification.Name {
  static let UserTokenSessionInvalidNotification = Notification.Name("UserTokenSessionInvalidNotification")
  static let UserTokenSessionExpiredNotification = Notification.Name("UserTokenSessionExpiredNotification")
  static let UserTokenSessionClosedNotification = Notification.Name("UserTokenSessionClosedNotification")
}