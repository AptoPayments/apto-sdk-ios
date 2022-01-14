//
//  NotificationHandlerImpl.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 30/10/2019.
//

import Foundation

public class NotificationHandlerImpl: NotificationHandler {
    private let notificationCenter: NotificationCenter

    public init(notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.notificationCenter = notificationCenter
    }

    public func postNotification(_ name: Notification.Name, object: AnyObject?, userInfo: [String: AnyObject]?) {
        notificationCenter.post(name: name, object: object, userInfo: userInfo)
    }

    public func addObserver(_ observer: AnyObject, selector: Selector, name: Notification.Name, object: AnyObject?) {
        notificationCenter.addObserver(observer, selector: selector, name: name, object: object)
    }

    public func removeObserver(_ observer: AnyObject) {
        notificationCenter.removeObserver(observer)
    }

    public func removeObserver(_ observer: AnyObject, name: Notification.Name, object: AnyObject?) {
        notificationCenter.removeObserver(observer, name: name, object: object)
    }
}
