//
//  ProjectDisclaimerScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

class WelcomeScreenScreen: Screen {
  
  struct Labels {
    static let FindALoanButton = "Find a Loan Button"
  }
  
  @discardableResult func agreeProjectDisclaimer() -> Self {
    uiTest.tester().tapView(withAccessibilityLabel: Labels.FindALoanButton)
    return self
  }
  
}
