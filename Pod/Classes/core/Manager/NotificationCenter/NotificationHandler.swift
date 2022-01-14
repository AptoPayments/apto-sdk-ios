//
//  NotificationHandler.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 30/10/2019.
//

import Foundation

public protocol NotificationHandler {
    func postNotification(_ name: Notification.Name, object: AnyObject?, userInfo: [String: AnyObject]?)
    func addObserver(_ observer: AnyObject, selector: Selector, name: Notification.Name, object: AnyObject?)
    func removeObserver(_ observer: AnyObject)
    func removeObserver(_ observer: AnyObject, name: Notification.Name, object: AnyObject?)
}

public extension NotificationHandler {
    func postNotification(_ name: Notification.Name, object: AnyObject? = nil, userInfo: [String: AnyObject]? = nil) {
        postNotification(name, object: object, userInfo: userInfo)
    }

    func addObserver(_ observer: AnyObject, selector: Selector, name: Notification.Name, object: AnyObject? = nil) {
        addObserver(observer, selector: selector, name: name, object: object)
    }

    func removeObserver(_ observer: AnyObject, name: Notification.Name, object: AnyObject? = nil) {
        removeObserver(observer, name: name, object: object)
    }
}
