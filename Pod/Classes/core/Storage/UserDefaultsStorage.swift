//
// UserDefaultsStorage.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 28/06/2019.
//

import Foundation

protocol UserDefaultsStorageProtocol {
  func object(forKey key: String) -> Any?
  func set(_ value: Bool, forKey key: String)
  func removeObject(forKey key: String)
}

class UserDefaultsStorage: UserDefaultsStorageProtocol {
  private let userDefaults = UserDefaults.standard

  func object(forKey key: String) -> Any? {
    return userDefaults.object(forKey: key)
  }

  func set(_ value: Bool, forKey key: String) {
    userDefaults.set(value, forKey: key)
  }

  func removeObject(forKey key: String) {
    userDefaults.removeObject(forKey: key)
  }
}
