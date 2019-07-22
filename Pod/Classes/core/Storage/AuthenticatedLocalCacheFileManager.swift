//
// AuthenticatedLocalCacheFileManager.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 28/11/2018.
//

import Foundation

class AuthenticatedLocalCacheFileManager: LocalCacheFileManagerProtocol {
  private let userTokenStorage: UserTokenStorageProtocol
  private var userToken: String? {
    guard let currentToken = userTokenStorage.currentToken(), let md5 = currentToken.md5 else {
      return nil
    }
    return md5
  }

  init(userTokenStorage: UserTokenStorageProtocol) {
    self.userTokenStorage = userTokenStorage
  }

  func write(data: Data, filename: String) throws {
    guard let userToken = self.userToken else { return }
    let directoryURL = try userDirectory(for: userToken)
    let documentURL = directoryURL.appendingPathComponent(filename)
    try data.write(to: documentURL, options: [.atomic, .completeFileProtection])
  }

  func read(filename: String) throws -> Data? {
    guard let userToken = self.userToken else { return nil }
    let directoryURL = try userDirectory(for: userToken)
    let documentURL = directoryURL.appendingPathComponent(filename)
    let data = try Data(contentsOf: documentURL)
    return data
  }

  func invalidate() throws {
    try FileManager.default.removeItem(at: sdkNamespaceDirectory())
  }
}

private extension AuthenticatedLocalCacheFileManager {
  func userDirectory(for token: String) throws -> URL {
    let url = try sdkNamespaceDirectory().appendingPathComponent(token)
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: url.path) {
      try fileManager.createDirectory(at: url,
                                      withIntermediateDirectories: true,
                                      attributes: [.protectionKey: FileProtectionType.complete])
    }
    return url
  }
}
