//
//  SelectAccountTypeScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 04/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class SelectAccountTypeScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "Fund Loan"
    static let SelectBankAccountButton = "Select Bank Account Button"
    static let IssueVirtualCardButton = "Issue Virtual Card Button"
    static let AddCardButton = "Add Card Button"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func selectBankAccount() -> Self {
    
    tapView(withAccessibilityLabel: Labels.SelectBankAccountButton)
    
    return self
    
  } // end selectBankAccount
  
  @discardableResult func addCard() -> Self {
    
    tapView(withAccessibilityLabel: Labels.AddCardButton)
    
    return self
    
  } // end addCard

  @discardableResult func issueVirtualCard() -> Self {
    
    tapView(withAccessibilityLabel: Labels.IssueVirtualCardButton)
    
    return self
    
  } // end issueVirtualCard
  
}
