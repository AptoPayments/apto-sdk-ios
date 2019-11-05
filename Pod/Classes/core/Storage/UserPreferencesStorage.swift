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
  private let notificationHandler: NotificationHandler

  var shouldShowDetailedCardActivity: Bool {
    get {
      return userDefaultsStorage.object(forKey: .showDetailedCardActivityKey) as? Bool ?? false
    }
    set {
      userDefaultsStorage.set(newValue, forKey: .showDetailedCardActivityKey)
    }
  }

  init(userDefaultsStorage: UserDefaultsStorageProtocol, notificationHandler: NotificationHandler) {
    self.userDefaultsStorage = userDefaultsStorage
    self.notificationHandler = notificationHandler
    registerNotifications()
  }

  deinit {
    notificationHandler.removeObserver(self)
  }

  private func registerNotifications() {
    notificationHandler.addObserver(self, selector: #selector(removePreferences),
                                    name: .UserTokenSessionExpiredNotification)
    notificationHandler.addObserver(self, selector: #selector(removePreferences),
                                    name: .UserTokenSessionInvalidNotification)
    notificationHandler.addObserver(self, selector: #selector(removePreferences),
                                    name: .UserTokenSessionClosedNotification)
  }

  @objc private func removePreferences() {
    userDefaultsStorage.removeObject(forKey: .showDetailedCardActivityKey)
  }
}

private extension String {
  static let showDetailedCardActivityKey = "apto.sdk.showDetailedCardActivity"
}
