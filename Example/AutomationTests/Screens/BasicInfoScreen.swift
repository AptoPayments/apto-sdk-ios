//
//  BasicInfoScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

class BasicUserInfoScreen: Screen {
  
  struct Labels {
    static let ViewControllerTitle = "Info"
    static let FirstNameField = "First Name Input Field"
    static let LastNameField = "Last Name Input Field"
    static let EmailField = "Email Input Field"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    // Check the view controller title
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func input(firstName: String) -> Self {
    enter(text:firstName, intoViewWithAccessibilityLabel: Labels.FirstNameField)
    return self
  }

  @discardableResult func input(lastName: String) -> Self {
    enter(text:lastName, intoViewWithAccessibilityLabel: Labels.LastNameField)
    return self
  }

  @discardableResult func input(email: String) -> Self {
    enter(text:email, intoViewWithAccessibilityLabel: Labels.EmailField)
    return self
  }

}
