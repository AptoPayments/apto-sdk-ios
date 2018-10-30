//
//  ServiceLocator.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

class ServiceLocator: ServiceLocatorProtocol {
  static let shared: ServiceLocatorProtocol = ServiceLocator()

  lazy var moduleLocator: ModuleLocatorProtocol = ModuleLocator(serviceLocator: self)
  lazy var presenterLocator: PresenterLocatorProtocol = PresenterLocator()
  lazy var interactorLocator: InteractorLocatorProtocol = InteractorLocator(serviceLocator: self)
  lazy var viewLocator: ViewLocatorProtocol = ViewLocator(serviceLocator: self)
  lazy var networkLocator: NetworkLocatorProtocol = NetworkLocator()
  lazy var storageLocator: StorageLocatorProtocol = StorageLocator()

  private(set) var session: ShiftSession = ShiftSession()
  var uiConfig: ShiftUIConfig! // swiftlint:disable:this implicitly_unwrapped_optional
}
