//
//  ServiceLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

class ServiceLocator: ServiceLocatorProtocol {
  static let shared: ServiceLocatorProtocol = ServiceLocator()

  lazy var networkLocator: NetworkLocatorProtocol = NetworkLocator(serviceLocator: self)
  lazy var storageLocator: StorageLocatorProtocol = StorageLocator(serviceLocator: self)

  lazy var platform: AptoPlatformProtocol = AptoPlatform.defaultManager()
  lazy var analyticsManager: AnalyticsServiceProtocol = AnalyticsManager.instance
  lazy var notificationHandler: NotificationHandler = NotificationHandlerImpl()
}
