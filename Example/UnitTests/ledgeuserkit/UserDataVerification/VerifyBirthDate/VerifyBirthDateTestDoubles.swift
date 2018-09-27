//
//  VerifyBirthDateTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/06/2018.
//
//

@testable import ShiftSDK

class VerifyBirthDateModuleSpy: UIModuleSpy, VerifyBirthDateModuleProtocol {
  var onVerificationPassed: ((VerifyBirthDateModule, Verification) -> Void)?
}
