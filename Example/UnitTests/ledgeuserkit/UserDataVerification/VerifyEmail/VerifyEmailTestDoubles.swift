//
//  VerifyEmailTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/06/2018.
//
//

@testable import ShiftSDK

class VerifyEmailModuleSpy: UIModuleSpy, VerifyEmailModuleProtocol {
  var onVerificationPassed: ((VerifyEmailModule, Verification) -> Void)?
}
