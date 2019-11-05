//
//  Device.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 11/08/16.
//
//

import Foundation

extension UIDevice {
  public var platform: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    return machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
  }
}
