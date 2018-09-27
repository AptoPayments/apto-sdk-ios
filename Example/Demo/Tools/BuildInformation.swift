//
//  BuildInformation.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 10/02/16.
//
//

import Foundation

open class BuildInformation {
  public static var version: String? {
    guard let retVal = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
      return nil
    }
    return retVal
  }

  public static var build: String? {
    guard let retVal = Bundle.main.infoDictionary?[String(kCFBundleVersionKey)] as? String else {
      return nil
    }
    return retVal
  }

  public static var buildType: NSString? {
    guard let retVal = Bundle.main.infoDictionary?["BuildType"] as? NSString else {
      return nil
    }
    return retVal
  }

  public static var buildDate: Date? {
    guard let retVal = Bundle.main.infoDictionary?["BuildDate"] as? Date else {
      return nil
    }
    return retVal
  }
}
