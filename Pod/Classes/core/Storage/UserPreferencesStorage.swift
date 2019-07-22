//
// UserPreferencesStorage.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 28/06/2019.
//

import Foundation

protocol UserPreferencesStorageProtocol {
  var shouldShowDetailedCardActivity: Bool { get set }
}

class UserPreferencesStorage: UserPreferencesStorageProtocol {
  private let userDefaultsStorage: UserDefaultsStorageProtocol

  var shouldShowDetailedCardActivity: Bool {
    get {
      return userDefaultsStorage.object(forKey: .showDetailedCardActivityKey) as? Bool ?? false
    }
    set {
      userDefaultsStorage.set(newValue, forKey: .showDetailedCardActivityKey)
    }
  }

  init(userDefaultsStorage: UserDefaultsStorageProtocol) {
    self.userDefaultsStorage = userDefaultsStorage
    registerNotifications()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func registerNotifications() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(removePreferences),
                                   name: .UserTokenSessionExpiredNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(removePreferences),
                                   name: .UserTokenSessionInvalidNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(removePreferences),
                                   name: .UserTokenSessionClosedNotification, object: nil)
  }

  @objc private func removePreferences() {
    userDefaultsStorage.removeObject(forKey: .showDetailedCardActivityKey)
  }
}

private extension String {
  static let showDetailedCardActivityKey = "apto.sdk.showDetailedCardActivity"
}
