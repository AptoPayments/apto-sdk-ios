//
//  VerifyPhoneTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/06/2018.
//
//

@testable import ShiftSDK

class VerifyPhoneModuleSpy: UIModuleSpy, VerifyPhoneModuleProtocol {
  open var onVerificationPassed: ((_ verifyPhoneModule: VerifyPhoneModule, _ verification: Verification) -> Void)?
}
