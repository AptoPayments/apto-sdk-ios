//
//  SDKLauncherScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

class SDKLauncherScreen: Screen {
  
  struct Labels {
    static let GetStarted = "Get Started"
    static let Settings = "Settings"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    waitForViewWith(accessibilityLabel: Labels.GetStarted)
    waitForViewWith(accessibilityLabel: Labels.Settings)
    return self
  }
  
  override func isScreenPresent() -> Bool {
    return isViewPresentWith(accessibilityLabel: Labels.GetStarted) && isViewPresentWith(accessibilityLabel: Labels.Settings)
  }
  
  @discardableResult func startShiftSDK() -> Self {
    tapView(withAccessibilityLabel: Labels.GetStarted)
    return self
  }
  
  @discardableResult func openSettingsScreen() -> Self {
    tapView(withAccessibilityLabel: Labels.Settings)
    return self
  }

}
