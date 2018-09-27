//
//  ServerMaintenanceErrorTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 18/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

@testable import ShiftSDK

class ServerMaintenanceErrorInteractorSpy:  ServerMaintenanceErrorInteractorProtocol {
  private(set) var runPendingRequestsCalled = false
  func runPendingRequests() {
    runPendingRequestsCalled = true
  }
}

class ServerMaintenanceErrorPresenterSpy: ServerMaintenanceErrorPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var router: ServerMaintenanceErrorModuleProtocol!
  var interactor: ServerMaintenanceErrorInteractorProtocol!
  // swiftlint:enable implicitly_unwrapped_optional

  private(set) var retryTappedCalled = false
  func retryTapped() {
    retryTappedCalled = true
  }
}

class ServerMaintenanceErrorModuleSpy: UIModule, ServerMaintenanceErrorModuleProtocol {
  private(set) var pendingRequestsExecutedCalled = false
  func pendingRequestsExecuted() {
    pendingRequestsExecutedCalled = true
  }
}
