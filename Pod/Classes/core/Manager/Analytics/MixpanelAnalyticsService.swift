//
//  MixpanelAnalyticsService.swift
//
//  Created by Pau Teruel on 14/03/2019.
//

import Foundation
import Mixpanel

final class MixpanelAnalyticsService: AnalyticsServiceProtocol {
  
  private var initialized = false
  private var tempCreateUserId: String?
  private var tempLoginUserId: String?

  func initialize(accessToken: String) {
    Mixpanel.initialize(token: accessToken, flushInterval: 60)
    initialized = true
    if let userId = tempCreateUserId {
      createUser(userId: userId)
      tempCreateUserId = nil
    }
    if let userId = tempLoginUserId {
      loginUser(userId: userId)
      tempLoginUserId = nil
    }
  }
  
  func track(event: Event, properties: [String: Any]? = [:]) {
    guard initialized else { return }
    let properties = properties as? Properties ?? nil
    Mixpanel.mainInstance().track(event: event.rawValue, properties: properties)
  }
  
  func createUser(userId: String) {
    guard initialized else {
      tempCreateUserId = userId
      return
    }
    let mixpanel = Mixpanel.mainInstance()
    mixpanel.createAlias(userId, distinctId: mixpanel.distinctId)
    mixpanel.identify(distinctId: userId)
    mixpanel.people.set(property: "userId", to: userId)
    mixpanel.registerSuperProperties(["userId": userId])
    track(event: Event.createUser)
  }
  
  func loginUser(userId: String) {
    guard initialized else {
      tempLoginUserId = userId
      return
    }
    let mixpanel = Mixpanel.mainInstance()
    mixpanel.identify(distinctId: userId)
    mixpanel.registerSuperProperties(["userId": userId])
    track(event: Event.loginUser)
  }
  
  func logoutUser() {
    guard initialized else { return }
    let mixpanel = Mixpanel.mainInstance()
    track(event: Event.logoutUser)
    mixpanel.clearSuperProperties()
    mixpanel.flush()
  }
}
