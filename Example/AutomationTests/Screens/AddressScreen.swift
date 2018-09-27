//
//  AddressScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 02/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class AddressScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "Address"
    static let AddressInputField = "Address Input Field"
    static let ZipInputField = "ZIP Input Field"
    static let CityInputField = "City Input Field"
    static let StateInputField = "State Input Field"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    waitForViewWith(accessibilityLabel: Labels.AddressInputField)
    waitForViewWith(accessibilityLabel: Labels.ZipInputField)
    waitForViewWith(accessibilityLabel: Labels.CityInputField)
    waitForViewWith(accessibilityLabel: Labels.StateInputField)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func input(address: String) -> Self {
    
    return enter(text: address, intoViewWithAccessibilityLabel: Labels.AddressInputField)
    
  } // end input(address)

  @discardableResult func input(zipCode: String) -> Self {
    
    return enter(text: zipCode, intoViewWithAccessibilityLabel: Labels.ZipInputField)
    
  } // end input(zipCode)
  
  @discardableResult func input(city: String) -> Self {
    
    return enter(text: city, intoViewWithAccessibilityLabel: Labels.CityInputField)
    
  } // end input(city)

  @discardableResult func input(state: String) -> Self {
    
    return selectPicker(value: state, intoViewWithAccessibilityLabel: Labels.StateInputField)
    
  } // end input(state)

}
