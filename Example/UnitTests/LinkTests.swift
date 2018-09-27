//
//  LinkTests.swift
//  LinkTests
//
//  Created by Ivan Oliver Martínez on 07/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest

class LinkTestCase: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
  func assertMockCalledOnce(mock: Mock, methodName:String, file: String = #file, line: UInt = #line) {
    let callCount = mock.callCount(methodName: methodName)
    if callCount != 1 {
      self.recordFailure(withDescription: "Method \(methodName) called \(callCount) times", inFile: file, atLine: Int(line), expected: true)
    }
  }
  
}

struct CallLog {
  
  let methodName: String
  var callCount: Int
  
}

protocol Mock {
  
  var callStack:[String:CallLog] { get set }
  
}

protocol Stub {
  
  var methodStubs:[String:AnyObject] { get set }
  
}

extension Mock {
  
  mutating func registerCall(methodName:String) {
    guard var callLog = callStack[methodName] else {
      callStack[methodName] = CallLog(methodName: methodName, callCount: 1)
      return
    }
    callLog.callCount = callLog.callCount + 1
  }
  
  func callCount(methodName:String) -> Int {
    guard let callLog = callStack[methodName] else {
      return 0
    }
    return callLog.callCount
  }
  
}

extension Stub {
  
  mutating func registerReturnValue(methodName:String, returnValue:AnyObject) {
    methodStubs[methodName] = returnValue
  }
  
  func returnValueFor(methodName:String) -> AnyObject? {
    return methodStubs[methodName]
  }
  
}
