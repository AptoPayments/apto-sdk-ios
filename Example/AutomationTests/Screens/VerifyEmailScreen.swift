//
//  VerifyEmailScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 21/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

class VerifyEmailScreen: Screen {
  
  struct Labels {
    static let VerifyEmailExplanation = "Verify Email Explanation"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    waitForViewWith(accessibilityLabel: Labels.VerifyEmailExplanation)
    return self
  }
  
}
