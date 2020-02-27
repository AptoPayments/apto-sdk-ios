//
//  LocalCacheFileManagerProtocol.swift
//  AptoSDK
//
//  Created by Fahad Naeem on 6/25/19.
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
  static let brandingFilename = "branding.plist"
}

extension LocalCacheFileManagerProtocol {
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
