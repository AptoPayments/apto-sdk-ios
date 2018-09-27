//
//  Screen.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import ReactiveKit
import ShiftSDK
import KIF

class Screen {
  
  let uiTest: ShiftUITest
  let tester: KIFUITestActor
  
  init(_ uiTest: ShiftUITest) {
    self.uiTest = uiTest
    self.tester = uiTest.tester()
  }
  
  @discardableResult func waitForScreen() -> Self {
    Swift.assert(true)
    return self
  }
  
  func isScreenPresent() -> Bool {
    return false
  }

  @discardableResult func next() -> Self {
    waitUntilEnabled(accessibilityLabel: "Navigation Next Button")
    tester.tapView(withAccessibilityLabel:"Navigation Next Button")
    return self
  }
  
  @discardableResult func previous() -> Self {
    waitUntilEnabled(accessibilityLabel: "Navigation Previous Button")
    tester.tapView(withAccessibilityLabel:"Navigation Previous Button")
    return self
  }
  
  @discardableResult func close() -> Self {
    tester.tapView(withAccessibilityLabel:"Navigation Close Button")
    return self
  }

  @discardableResult func previousIfAvailable() -> Self {
    if self.previousAvailable() {
      self.previous()
    }
    return self
  }
  
  @discardableResult func closeIfAvailable() -> Self {
    if self.closeAvailable() {
      self.close()
    }
    return self
  }
  
  func nextAvailable() -> Bool {
    return self.isViewPresentWith(accessibilityLabel: "Navigation Next Button")
  }

  func previousAvailable() -> Bool {
    return self.isViewPresentWith(accessibilityLabel: "Navigation Previous Button")
  }

  func closeAvailable() -> Bool {
    return self.isViewPresentWith(accessibilityLabel: "Navigation Close Button")
  }

  @discardableResult func tapView(withAccessibilityLabel:String) -> Self {
    tester.tapView(withAccessibilityLabel:withAccessibilityLabel)
    return self
  }
  
  @discardableResult func set(text:String, intoViewWithAccessibilityLabel:String) -> Self {
    
    /*
     There's no way to deactivate the final text checking that kif does. That generates several issues that can't be addressed by now.
    let length = text.characters.count
    
    if length < 1 {
      tester.setText(text, intoViewWithAccessibilityLabel:intoViewWithAccessibilityLabel)
    }
    else {
      let prefix = String(text.characters.prefix(text.characters.count - 1))
      let suffix = String(text.characters.suffix(1))
      tester.setText(prefix, intoViewWithAccessibilityLabel:intoViewWithAccessibilityLabel)
      tester.enterText(suffix, intoViewWithAccessibilityLabel:intoViewWithAccessibilityLabel, traits:UIAccessibilityTraitNone, expectedResult:text)
    }
    */
    
    tester.setText(text, intoViewWithAccessibilityLabel:intoViewWithAccessibilityLabel)
    return self
  }
  
  @discardableResult func enter(text:String, intoViewWithAccessibilityLabel:String, expectedResult:String? = nil) -> Self {
    tapView(withAccessibilityLabel:intoViewWithAccessibilityLabel)
    if let expectedResult = expectedResult {
      tester.enterText(text, intoViewWithAccessibilityLabel:intoViewWithAccessibilityLabel, traits:UIAccessibilityTraitNone, expectedResult:expectedResult)
    }
    else {
      tester.enterText(intoCurrentFirstResponder: text)
    }
    return self
  }
  
  @discardableResult func selectSlider(value: Int, intoViewWithAccessibilityLabel:String) -> Self {
    guard let slider = viewWith(accessibilityLabel: intoViewWithAccessibilityLabel) as? FormRowNumericSliderView else {
      fail()
      return self
    }
    slider.bndNumber.next(value)
    return self
  }
  
  @discardableResult func selectPicker(value: String, intoViewWithAccessibilityLabel:String) -> Self {
    tapView(withAccessibilityLabel: intoViewWithAccessibilityLabel)
    tester.selectPickerViewRow(withTitle: value)
    return self
  }
  
  @discardableResult func selectDatePicker(date: Date, intoViewWithAccessibilityLabel:String) -> Self {
    
    let monthFormatter = DateFormatter()
    monthFormatter.dateFormat = "MMMM"
    let month = monthFormatter.string(from: date)
    
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let day = calendar.component(.day, from: date)
    
    tapView(withAccessibilityLabel: intoViewWithAccessibilityLabel)
    tester.selectDatePickerValue([month, "\(day)", "\(year)"])
    return self
  }

  @discardableResult func fail() -> Self {
    tester.fail()
    return self
  }
  
  @discardableResult func waitUntilAvailable(_ function:() -> AnyObject?) -> Self {
    var counter = 0
    while counter < 10 {
      if function() != nil {
        return self
      }
      else {
        tester.wait(forTimeInterval: 1)
        counter = counter + 1
      }
    }
    fail()
    return self
  }
  
  @discardableResult func waitUntilEnabled(accessibilityLabel:String) -> Self {
    var counter = 0
    while counter < 10 {
      if let view = viewWith(accessibilityLabel: accessibilityLabel) as? UIControl, view.isEnabled {
        return self
      }
      tester.wait(forTimeInterval: 0.2)
      counter = counter + 1
    }
    fail()
    return self
  }
  
  @discardableResult func waitForViewWith(accessibilityLabel:String) -> Self {
    tester.waitForView(withAccessibilityLabel: accessibilityLabel)
    return self
  }

  func viewWith(accessibilityLabel:String) -> UIView {
    return tester.waitForView(withAccessibilityLabel: accessibilityLabel)
  }
  
  func isViewPresentWith(accessibilityLabel:String) -> Bool {
    do {
      try tester.tryFindingView(withAccessibilityLabel: accessibilityLabel)
      return true
    }
    catch {
      return false
    }
    
  }
  
  func wait(seconds: UInt32) -> Self{
    sleep(seconds)
    return self
  }

}
