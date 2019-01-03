//
// StringLocalizationStorage.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 06/11/2018.
//

class StringLocalizationStorage {
  private var cache: [String: String] = [:]

  static let shared = StringLocalizationStorage()

  private init() {
  }

  func append(_ content: [String: String]) {
    cache.merge(content) { (_, new) in new }
  }

  func localizedString(for key: String) -> String? {
    return cache[key]
  }
}
