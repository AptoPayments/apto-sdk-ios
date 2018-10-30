//
//  PhoneCaller.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 23/10/2018.
//

import CallKit

protocol PhoneCallerProtocol {
  func call(phoneNumberURL: URL, from module: UIModule, completion: @escaping () -> Void)
}

class PhoneCaller: NSObject, PhoneCallerProtocol, CXCallObserverDelegate {
  private var callObserver: CXCallObserver?
  private var onCallEnded: (() -> Void)?

  func call(phoneNumberURL: URL, from module: UIModule, completion: @escaping () -> Void) {
    let callObserver = CXCallObserver()
    callObserver.setDelegate(self, queue: nil)
    onCallEnded = completion
    self.callObserver = callObserver
    module.showExternal(url: phoneNumberURL, useSafari: true)
  }

  public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
    if call.hasConnected && call.hasEnded {
      onCallEnded?()
      self.callObserver?.setDelegate(nil, queue: nil)
      self.callObserver = nil
    }
  }
}

// This class has been declared in the SDK itself to be able to manual test the functionality without requiring a phone
// call. In order to use it just inject an instance of the class instead of an instance of PhoneCaller.
class DummyPhoneCaller: PhoneCallerProtocol {
  func call(phoneNumberURL: URL, from module: UIModule, completion: @escaping () -> Void) {
    completion()
  }
}
