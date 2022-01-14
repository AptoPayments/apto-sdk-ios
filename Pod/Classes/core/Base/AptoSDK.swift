//
//  AptoSDK.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 05/09/2018.
//
//

public final class AptoSDK {
    private static let internalVersion = "0.0.0"

    private static var _version: String?
    public static var version: String {
        if let loadedVersion = _version {
            return loadedVersion
        }
        let bundle = Bundle(for: AptoSDK.self)
        if let bundleVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            _version = bundleVersion
            return bundleVersion
        }
        return internalVersion
    }

    private static var _appVersion: String?
    public static var appVersion: String {
        if let loadedVersion = _appVersion {
            return loadedVersion
        }
        let bundle = Bundle.main
        if let bundleVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            _appVersion = bundleVersion
            return bundleVersion
        }
        return internalVersion
    }

    public static var fullVersion: String {
        "\(appVersion) - (\(version))"
    }
}
