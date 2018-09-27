//
//  NetworkManagerSpy.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 18/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

@testable import ShiftSDK
import Alamofire

class NetworkManagerSpy: NetworkManagerProtocol {
  var delegate: SessionDelegate {
    return SessionDelegate()
  }

  private(set) var requestCalled = false
  private(set) var lastNetworkRequest: NetworkRequest?
  func request(_ networkRequest: NetworkRequest) {
    requestCalled = true
    lastNetworkRequest = networkRequest
  }

  private(set) var runPendingRequestsCalled = false
  func runPendingRequests() {
    runPendingRequestsCalled = true
  }
}
