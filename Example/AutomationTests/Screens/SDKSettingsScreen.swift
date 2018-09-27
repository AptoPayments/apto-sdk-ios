//
//  SDKSettingsScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 31/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class SDKSettingsScreen: Screen {
  
  struct Labels {
    static let ViewControllerTitle = "Settings"
    static let TeamKeyField = "teamKeyTextField"
    static let ProjectKeyField = "projectKeyTextField"
    static let ClearUserTokenButton = "Clear User Token"
    static let SaveButton = "Save"
  }
  
  override func waitForScreen() -> Self {
    
    // Check the view controller title
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func clearUserToken() -> Self {
    
    if isViewPresentWith(accessibilityLabel: Labels.ClearUserTokenButton) {
      tapView(withAccessibilityLabel: Labels.ClearUserTokenButton)
    }
    
    return self
    
  } // end clearUserToken
  
  @discardableResult func configure(teamKey: String?, projectKey: String?) -> Self {
    
    // Fill in the team key
    if let teamKey = teamKey {
      set(text: "", intoViewWithAccessibilityLabel: Labels.TeamKeyField)
      enter(text: teamKey, intoViewWithAccessibilityLabel: Labels.TeamKeyField)
      uiTest.tester().expect(uiTest.tester().waitForView(withAccessibilityLabel: Labels.TeamKeyField), toContainText:teamKey)
    }
    
    // Fill in the project key
    if let projectKey = projectKey {
      set(text: "", intoViewWithAccessibilityLabel: Labels.ProjectKeyField)
      enter(text: projectKey, intoViewWithAccessibilityLabel: Labels.ProjectKeyField)
      uiTest.tester().expect(uiTest.tester().waitForView(withAccessibilityLabel: Labels.ProjectKeyField), toContainText:projectKey)
    }
    
    // Save the changes
    tapView(withAccessibilityLabel: Labels.SaveButton)
    
    return self
    
  } // end configure(teamKey,projectKey)
  
}
