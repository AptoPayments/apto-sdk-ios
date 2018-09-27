//
//  AppDelegate.swift
//  TEST
//
//  Created by Ivan Oliver on 01/25/2016.
//  Copyright (c) 2016 Ivan Oliver. All rights reserved.
//

import UIKit
import HockeySDK
import LedgeLink

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let manager = LedgeLink.defaultManager()
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    // Override point for customization after application launch.
    
    if ALPHA_BUILD {
      BITHockeyManager.sharedHockeyManager().configureWithIdentifier("5748ea6af72c4b98963d67850ec05b5c")
      BITHockeyManager.sharedHockeyManager().disableCrashManager = true
      BITHockeyManager.sharedHockeyManager().startManager()
      BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
    }
    else if BETA_BUILD {
      BITHockeyManager.sharedHockeyManager().configureWithIdentifier("50b1c0ff18af43d69910ba14c17e2833")
      BITHockeyManager.sharedHockeyManager().disableCrashManager = true
      BITHockeyManager.sharedHockeyManager().startManager()
      BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
    }
    
    // Make sure the user token is cleared when the app is opened
    LedgeLink.defaultManager().clearUserToken()
    
    return true
    
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {

    manager.handle(url) { result in
      switch result {
      case .Failure(let error):
        self.showMessage(error.localizedDescription)
      case .Success(let result):
        switch result {
        case .NoPendingApplications:
          self.showMessage("app-delegate.alert.no-additional-documentation-required".podLocalized())
        case .Success:
          self.showMessage("app-delegate.alert.file-added-to-application".podLocalized())
        case .UnsupportedFileFormat:
          self.showMessage("app-delegate.alert.unsupported-file-format".podLocalized())
        case .UndefinedUserToken:
          self.showMessage("app-delegate.alert.invalid-session".podLocalized())
        case .UserCancelled:
          break
        }
      }
    }
    return true
  }
  
  private func showMessage(message:String) {
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
    UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
  }
  
}

