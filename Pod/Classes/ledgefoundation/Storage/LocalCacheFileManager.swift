//
// LocalCacheFileManager.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 28/11/2018.
//

import Foundation

protocol LocalCacheFileManagerProtocol {
  func write(data: Data, filename: String) throws
  func read(filename: String) throws -> Data?
  func invalidate() throws
}

extension String {
  static let fundingSourceFilename = "fundingSource.plist"
  static let fundingSourceListFilename = "fundingSourceList.plist"
  static let cardsFilename = "cards.plist"
  static let transactionsFilename = "transactions.plist"
}

class LocalCacheFileManager: LocalCacheFileManagerProtocol {
  private let userTokenStorage: UserTokenStorageProtocol
  var userToken: String? {
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

private extension LocalCacheFileManager {
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

  func sdkNamespaceDirectory() throws -> URL {
    let fileManager = FileManager.default
    let documentDirectory = try fileManager.url(for: .documentDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: true)
    let sdkNamespace = "com.shiftpayments.sdk"
    return documentDirectory.appendingPathComponent(sdkNamespace)
  }
}
