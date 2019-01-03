//
//  UIDevice.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 14/08/2018.
//

import UIKit

public enum UIDeviceType {
  case iPhone5
  case iPhone678
  case iPhone678Plus
  case iPhoneX
  case iPhoneUnknown
  case unknown
}

public extension UIDevice {
  public static func deviceType() -> UIDeviceType {
    if UIDevice().userInterfaceIdiom == .phone {
      switch UIScreen.main.nativeBounds.height {
      case 1136:
        return .iPhone5
      case 1334:
        return .iPhone678
      case 1920, 2208:
        return .iPhone678Plus
      case 2436:
        return .iPhoneX
      default:
        return .iPhoneUnknown
      }
    }
    return .unknown
  }
}
