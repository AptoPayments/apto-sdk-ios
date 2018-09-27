//
//  NetIncomeScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 02/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class NetIncomeScreen: Screen {

  struct Labels {
    static let ViewControllerTitle = "Income"
    static let NetIncomeSliderField = "Net Income Slider"
  }
  
  @discardableResult override func waitForScreen() -> Self {
    
    waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
    waitForViewWith(accessibilityLabel: Labels.NetIncomeSliderField)
    
    return self
    
  } // end waitForScreen
  
  @discardableResult func select(netIncome: Int) -> Self {
    
    return selectSlider(value: netIncome, intoViewWithAccessibilityLabel: Labels.NetIncomeSliderField)
    
  } // end select(netIncome)
  
}
