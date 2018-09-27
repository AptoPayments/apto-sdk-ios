//
//  NetworkLocatorFake.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

@testable import ShiftSDK

class NetworkLocatorFake: NetworkLocatorProtocol {
  lazy var networkManagerSpy: NetworkManagerSpy = NetworkManagerSpy()
  func networkManager(baseURL: URL?,
                      certPinningConfig: [String: [String: AnyObject]]?,
                      allowSelfSignedCertificate: Bool) -> NetworkManagerProtocol {
    return networkManagerSpy
  }

  func jsonTransport(environment: JSONTransportEnvironment,
                     baseUrlProvider: BaseURLProvider,
                     certPinningConfig: [String: [String: AnyObject]]?,
                     allowSelfSignedCertificate: Bool) -> JSONTransport {
    Swift.fatalError("jsonTransport not implemented")
  }
}
