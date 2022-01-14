//
//  AnalyticsService.swift
//
//  Created by Pau Teruel on 14/03/2019.
//

import Foundation

public protocol AnalyticsServiceProtocol {
    func initialize(accessToken: String)
    func track(event: Event, properties: [String: Any]?)
    func createUser(userId: String)
    func loginUser(userId: String)
    func logoutUser()
}

public extension AnalyticsServiceProtocol {
    func track(event: Event, properties: [String: Any]? = nil) {
        return track(event: event, properties: properties)
    }
}
