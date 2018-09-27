//
//  BuildInformation.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 10/02/16.
//
//

import Foundation

public class BuildInformation {
  
  public static var version: String? {
    guard let retVal = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String else {
      return nil
    }
    return retVal
  }
  
  public static var build: String? {
    guard let retVal = NSBundle.mainBundle().infoDictionary?[String(kCFBundleVersionKey)] as? String else {
      return nil
    }
    return retVal
  }

  public static var buildType: NSString? {
    guard let retVal = NSBundle.mainBundle().infoDictionary?["BuildType"] as? NSString else {
      return nil
    }
    return retVal
  }

  public static var buildDate: NSDate? {
    guard let retVal = NSBundle.mainBundle().infoDictionary?["BuildDate"] as? NSDate else {
      return nil
    }
    return retVal
  }
  
}
