//
//  CreditScoreScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 02/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class CreditScoreScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "Credit Score"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func select(creditScore: String) -> Self {
    
    tapView(withAccessibilityLabel: creditScore)
    
    return self
    
  } // end select(creditScore)
  
}
