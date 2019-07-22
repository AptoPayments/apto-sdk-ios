//
//  PushNotificationsManager.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 24/05/2018.
//

import UIKit
import UserNotifications

class PushNotificationsManager {
  func registerForPushNotifications() {
    DispatchQueue.main.async {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
        guard granted else {
          return
        }
        self.getNotificationSettings()
      }
    }
  }

  func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      DispatchQueue.main.async {
        guard settings.authorizationStatus == .authorized else {
          return
        }
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }

  func newPushTokenReceived(deviceToken: Data) -> String {
    let tokenParts = deviceToken.map { data -> String in
      return String(format: "%02.2hhx", data)
    }
    let token = tokenParts.joined()
    return token
  }

  func didFailToRegisterForRemoteNotificationsWithError(error: Error) {
    print("Failed to register to push notifications service: \(error)")
  }

  func didReceiveRemoteNotificationWith(userInfo: [AnyHashable: Any],
                                        completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if userInfo["aps"] is [String: AnyObject] {
    }
    else {
      completionHandler(.noData)
    }
  }
}
