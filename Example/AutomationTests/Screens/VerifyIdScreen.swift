//
//  VerifyIdScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 02/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class VerifyIdScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "Get Offers"
    static let BirthdateInputField = "Birthdate Input Field"
    static let SSNInputField = "SSN Input Field"
    static let getOffersButton = "Get Offers Button"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    waitForViewWith(accessibilityLabel: Labels.BirthdateInputField)
    waitForViewWith(accessibilityLabel: Labels.SSNInputField)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func input(birthdate: Date) -> Self {
    
    return selectDatePicker(date: birthdate, intoViewWithAccessibilityLabel: Labels.BirthdateInputField)
    
  } // end input(birthdate)

  @discardableResult func input(ssn: String) -> Self {
    
    return enter(text: ssn, intoViewWithAccessibilityLabel: Labels.SSNInputField)
    
  } // end input(ssn)

  @discardableResult func getOffers() -> Self {
    
    return tapView(withAccessibilityLabel: Labels.getOffersButton)
    
  } // end getOffers
  
}
