//
//  ServerMaintenanceErrorPresenter.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

class ServerMaintenanceErrorPresenter: ServerMaintenanceErrorPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var router: ServerMaintenanceErrorModuleProtocol!
  var interactor: ServerMaintenanceErrorInteractorProtocol!
  // swiftlint:enable implicitly_unwrapped_optional

  func retryTapped() {
    router.pendingRequestsExecuted()
    interactor.runPendingRequests()
  }
}
