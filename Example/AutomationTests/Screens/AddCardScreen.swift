//
//  AddCardScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 04/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class AddCardScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "Add Card"
    static let CardDataField = "Card Data Field"
    static let AddCardButton = "Add Card Button"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func enter(cardNumber: String, expirationDate: String, cvv: String) -> Self {
    
    enter(text:cardNumber, intoViewWithAccessibilityLabel: Labels.CardDataField)
    enter(text:expirationDate, intoViewWithAccessibilityLabel: Labels.CardDataField)
    enter(text:cvv, intoViewWithAccessibilityLabel: "CVC")
    
    return self
    
  } // end enterCardNumber:expirationDate

  @discardableResult func addCard() -> Self {
    
    tapView(withAccessibilityLabel: Labels.AddCardButton)

    return self
    
  } // end addCard
  
}
