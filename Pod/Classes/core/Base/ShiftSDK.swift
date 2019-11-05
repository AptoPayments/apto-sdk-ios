//
//  AptoSDK.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 05/09/2018.
//
//

public final class ShiftSDK {
  private static let internalVersion = "0.0.0"

  private static var _version: String?
  public static var version: String {
    if let loadedVersion = _version {
      return loadedVersion
    }
    let bundle = Bundle(for: ShiftSDK.self)
    if let bundleVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String {
      _version = bundleVersion
      return bundleVersion
    }
    return internalVersion
  }
}
