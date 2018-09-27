//
//  TimeAtAddressScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 02/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class TimeAtAddressScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "Address"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func select(timeAtAddress: String) -> Self {
    
    tapView(withAccessibilityLabel: timeAtAddress)
    
    return self
    
  } // end select(timeAtAddress)
  
}
