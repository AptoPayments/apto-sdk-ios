//
//  ShowCardScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 03/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class ShowCardScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "Card"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    
    return self
    
  } // end waitForScreen
  
}
