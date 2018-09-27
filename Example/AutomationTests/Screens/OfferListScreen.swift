//
//  OfferListScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 02/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class OfferListScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "My Loan Offers"
    static let ApplyToOfferButton = "Apply To Offer Button"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func applyToFirstOffer() -> Self {
    
    tapView(withAccessibilityLabel: "\(Labels.ApplyToOfferButton) 1")
    
    return self
    
  } // end applyToFirstOffer
  
}
