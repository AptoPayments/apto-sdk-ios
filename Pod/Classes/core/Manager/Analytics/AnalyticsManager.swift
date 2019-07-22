//
//  AnalyticsManager.swift
//
//  Created by Pau Teruel on 14/03/2019.
//

import Foundation

public final class AnalyticsManager: AnalyticsServiceProtocol {
  private let service = MixpanelAnalyticsService()
  public static let instance = AnalyticsManager()

  private init() {
  }

  public func initialize(accessToken: String) {
    service.initialize(accessToken: accessToken)
  }

  public func track(event: Event, properties: [String: Any]? = [:]) {
    service.track(event: event, properties: properties)
  }

  public func createUser(userId: String) {
    service.createUser(userId: userId)
  }

  public func loginUser(userId: String) {
    service.loginUser(userId: userId)
  }

  public func logoutUser() {
    service.logoutUser()
  }
}
