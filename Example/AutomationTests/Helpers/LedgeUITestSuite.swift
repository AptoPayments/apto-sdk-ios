//
//  ShiftUITestSuite.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 31/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

extension ShiftUITest {

  func resetSDK() {
    
    var counter = 0
    while counter < 10 {
      
      if (SDKLauncherScreen(self).isScreenPresent()) {
        return
      }
      else {
        let currentScreen = Screen(self)
        if currentScreen.previousAvailable() {
          currentScreen.previous()
        }
        else if currentScreen.closeAvailable() {
          currentScreen.close()
        }
        tester().wait(forTimeInterval: 0.1)
        counter = counter + 1
      }
      
    }

    tester().fail()
    return
    
  } // end resetSDK
  
  func configure(teamKey: String?, projectKey: String?) {
    
    // Configure Team and Project keys
    SDKLauncherScreen(self)
      .waitForScreen()
      .openSettingsScreen()
    
    SDKSettingsScreen(self)
      .waitForScreen()
      .clearUserToken()
      .configure(teamKey: teamKey, projectKey: projectKey)
    
  } // end configure(teamKey, projectKey)
  
}
