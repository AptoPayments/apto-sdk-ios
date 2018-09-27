//
//  SelectAccountScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 04/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class SelectAccountScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "Funding Account"
    static let AddAccountButton = "Add Account Button"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func addAccount() -> Self {
    
    tapView(withAccessibilityLabel: Labels.AddAccountButton)
    
    return self
    
  } // end selectBankAccount
  
}
