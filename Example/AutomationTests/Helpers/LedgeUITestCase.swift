//
//  ShiftUITestCase.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 17/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import KIF

class ShiftUITest: KIFTestCase {
  
  var helper: TestHelper!
  
  override func beforeAll() {
    disableAnimations()
  }
  override func beforeEach() {
    helper = TestHelper()
    resetSDK()
  }
  
  override func afterEach() {
    helper?.clean()
    helper = nil
  }
  
  func tester(file : String = #file, _ line : Int = #line) -> KIFUITestActor {
    return KIFUITestActor(inFile: file, atLine: line, delegate: self)
  }
  
  func system(file : String = #file, _ line : Int = #line) -> KIFSystemTestActor {
    return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
  }
  
  fileprivate func disableAnimations() {
    guard let keyWindow = UIApplication.shared.keyWindow else {
      return
    }
    keyWindow.layer.speed = 10.0
  }
  
  func dateFromString(date:String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMddyyyy"
    return formatter.date(from: date)
  }
    
}
