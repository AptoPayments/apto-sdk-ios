//
//  NetworkLocatorProtocol.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

protocol NetworkLocatorProtocol {
    func networkManager(baseURL: URL?,
                        certPinningConfig: [String: [String: AnyObject]]?,
                        allowSelfSignedCertificate: Bool) -> NetworkManagerProtocol

    func jsonTransport(environment: JSONTransportEnvironment,
                       baseUrlProvider: BaseURLProvider,
                       certPinningConfig: [String: [String: AnyObject]]?,
                       allowSelfSignedCertificate: Bool) -> JSONTransport
}

extension NetworkLocatorProtocol {
    func networkManager(baseURL: URL? = nil,
                        certPinningConfig: [String: [String: AnyObject]]? = nil,
                        allowSelfSignedCertificate: Bool = false) -> NetworkManagerProtocol
    {
        return networkManager(baseURL: baseURL,
                              certPinningConfig: certPinningConfig,
                              allowSelfSignedCertificate: allowSelfSignedCertificate)
    }

    func jsonTransport(environment: JSONTransportEnvironment,
                       baseUrlProvider: BaseURLProvider,
                       certPinningConfig: [String: [String: AnyObject]]? = nil,
                       allowSelfSignedCertificate: Bool = false) -> JSONTransport
    {
        return jsonTransport(environment: environment,
                             baseUrlProvider: baseUrlProvider,
                             certPinningConfig: certPinningConfig,
                             allowSelfSignedCertificate: allowSelfSignedCertificate)
    }
}
