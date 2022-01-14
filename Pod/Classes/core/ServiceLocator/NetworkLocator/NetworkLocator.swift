//
//  NetworkLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

import UIKit

class NetworkLocator: NetworkLocatorProtocol {
    private unowned let serviceLocator: ServiceLocatorProtocol

    init(serviceLocator: ServiceLocatorProtocol) {
        self.serviceLocator = serviceLocator
    }

    private var _networkManager: NetworkManager?
    func networkManager(baseURL: URL?,
                        certPinningConfig: [String: [String: AnyObject]]?,
                        allowSelfSignedCertificate: Bool) -> NetworkManagerProtocol
    {
        if let manager = _networkManager {
            return manager
        }

        let manager = NetworkManager(baseURL: baseURL, certPinningConfig: certPinningConfig,
                                     allowSelfSignedCertificate: allowSelfSignedCertificate,
                                     notificationHandler: serviceLocator.notificationHandler)
        _networkManager = manager

        return manager
    }

    private var _jsonTransport: JSONTransport?
    func jsonTransport(environment: JSONTransportEnvironment,
                       baseUrlProvider: BaseURLProvider,
                       certPinningConfig: [String: [String: AnyObject]]?,
                       allowSelfSignedCertificate: Bool) -> JSONTransport
    {
        if let transport = _jsonTransport {
            return transport
        }

        let manager = networkManager(baseURL: URL(string: baseUrlProvider.baseUrl(environment)),
                                     certPinningConfig: certPinningConfig,
                                     allowSelfSignedCertificate: allowSelfSignedCertificate)
        let transport = JSONTransportImpl(environment: environment,
                                          baseUrlProvider: baseUrlProvider,
                                          networkManager: manager)
        _jsonTransport = transport

        return transport
    }
}
