//
//  LocalCacheFileManager.swift
//  AptoSDK
//
//  Created by Fahad Naeem on 6/12/19.
//

import Foundation

class LocalCacheFileManager: LocalCacheFileManagerProtocol {
  func write(data: Data, filename: String) throws {
    let directoryURL = try sdkProjectDirectory()
    let documentURL = directoryURL.appendingPathComponent(filename)
    try data.write(to: documentURL, options: [.atomic, .completeFileProtection])
  }

  func read(filename: String) throws -> Data? {
    let directoryURL = try sdkProjectDirectory()
    let documentURL = directoryURL.appendingPathComponent(filename)
    let data = try Data(contentsOf: documentURL)
    return data
  }

  func invalidate() throws {
    try FileManager.default.removeItem(at: sdkNamespaceDirectory())
  }
}

private extension LocalCacheFileManager {
  func sdkProjectDirectory() throws -> URL {
    let url = try sdkNamespaceDirectory()
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: url.path) {
      try fileManager.createDirectory(at: url,
                                      withIntermediateDirectories: true,
                                      attributes: [.protectionKey: FileProtectionType.complete])
    }
    return url
  }
}
