//
//  ServerMaintenanceErrorInteractor.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

class ServerMaintenanceErrorInteractor: ServerMaintenanceErrorInteractorProtocol {
  private let networkManager: NetworkManagerProtocol

  init(networkManager: NetworkManagerProtocol) {
    self.networkManager = networkManager
  }

  func runPendingRequests() {
    networkManager.runPendingRequests()
  }
}
