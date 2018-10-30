//
//  PhoneCaller.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 23/10/2018.
//

@testable import ShiftSDK

class PhoneCallerSpy: DummyPhoneCaller {
  private(set) var callCalled = false
  override func call(phoneNumberURL: URL, from module: UIModule, completion: @escaping () -> Void) {
    callCalled = true
    super.call(phoneNumberURL: phoneNumberURL, from: module, completion: completion)
  }
}
