//
//  CollectLoanDataScreen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

class CollectLoanDataScreen: Screen {
  
  struct Labels {
    static let AmountSliderField = "Loan Amount Slider"
    static let PurposeField = "Loan Purpose Picker"
    static let GetOffersButton = "Get Offers Button"
  }
  
  @discardableResult func selectLoan(amount:Int) -> Self {
    
    return selectSlider(value: amount, intoViewWithAccessibilityLabel: Labels.AmountSliderField)
    
  } // end selectLoan(amount)
  
  @discardableResult func selectLoan(purpose:String) -> Self  {
    
    return selectPicker(value: purpose, intoViewWithAccessibilityLabel: Labels.PurposeField)
    
  } // end selectLoan(purpose)
  
  @discardableResult func getOffers() -> Self  {
    
    return tapView(withAccessibilityLabel: Labels.GetOffersButton)
    
  } // end selectLoan(purpose)

}
