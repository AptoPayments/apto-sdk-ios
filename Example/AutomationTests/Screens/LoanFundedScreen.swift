//
//  LoanFundedScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 04/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class LoanFundedScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "Loan Funded"
    static let ViewVirtualCardButton = "View Virtual Card"
    static let ViewCardButton = "View Card"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func viewVirtualCard() -> Self {
    
    tapView(withAccessibilityLabel: Labels.ViewVirtualCardButton)
    
    return self
    
  } // end viewVirtualCard
  
  @discardableResult func viewCard() -> Self {
    
    tapView(withAccessibilityLabel: Labels.ViewCardButton)
    
    return self
    
  } // end viewCard

}
