//
//  ServiceLocatorProtocol.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

protocol ServiceLocatorProtocol: AnyObject {
    var networkLocator: NetworkLocatorProtocol { get }
    var storageLocator: StorageLocatorProtocol { get }

    var platform: AptoPlatformProtocol { get }
    var analyticsManager: AnalyticsServiceProtocol { get }
    var notificationHandler: NotificationHandler { get }
}
