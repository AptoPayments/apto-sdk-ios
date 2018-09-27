//
//  ServiceLocatorFake.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

@testable import ShiftSDK

class ServiceLocatorFake: ServiceLocatorProtocol {
  lazy var moduleLocator: ModuleLocatorProtocol = moduleLocatorFake
  lazy var moduleLocatorFake: ModuleLocatorFake = ModuleLocatorFake(serviceLocator: self)

  lazy var presenterLocator: PresenterLocatorProtocol = presenterLocatorFake
  lazy var presenterLocatorFake: PresenterLocatorFake = PresenterLocatorFake()

  lazy var interactorLocator: InteractorLocatorProtocol = interactorLocatorFake
  lazy var interactorLocatorFake: InteractorLocatorFake = InteractorLocatorFake()

  lazy var viewLocator: ViewLocatorProtocol = ViewLocatorFake()

  lazy var networkLocator: NetworkLocatorProtocol = networkLocatorFake
  lazy var networkLocatorFake: NetworkLocatorFake = NetworkLocatorFake()

  lazy var storageLocator: StorageLocatorProtocol = storageLocatorFake
  lazy var storageLocatorFake: StorageLocatorFake = StorageLocatorFake()

  private(set) var sessionFake: ShiftSessionFake = ShiftSessionFake()
  var session: ShiftSession {
    return sessionFake
  }
}

// ShiftSession configuration methods
extension ServiceLocatorFake {
  func setUpSessionForContextConfigurationSuccess() {
    let dataProvider = ModelDataProvider.provider
    let contextConfiguration = ContextConfiguration(teamConfiguration: dataProvider.teamConfig,
                                                    projectConfiguration: dataProvider.projectConfiguration)
    sessionFake.nextContextConfigurationResult = .success(contextConfiguration)
  }

  func setUpSessionForContextConfigurationFailure() {
    sessionFake.nextContextConfigurationResult = .failure(defaultError())
  }

  func setUpSessionForLoginUserWithVerificationSuccess() {
    sessionFake.nextLoginUserResult = .success(ModelDataProvider.provider.user)
  }

  func setUpSessionForLoginUserWithVerificationFailure() {
    sessionFake.nextLoginUserResult = .failure(defaultError())
  }

  func setUpSessionForCreateUserSuccess() {
    sessionFake.nextCreateUserResult = .success(ModelDataProvider.provider.user)
  }

  func setUpSessionForCreateUserFailure() {
    sessionFake.nextCreateUserResult = .failure(defaultError())
  }

  private func defaultError() -> NSError {
    return NSError(domain: "com.shiftpayments.error", code: 1)
  }
}
