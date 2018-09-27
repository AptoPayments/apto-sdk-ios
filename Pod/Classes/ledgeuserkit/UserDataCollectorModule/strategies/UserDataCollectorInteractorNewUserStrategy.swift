//
//  UserDataCollectorInteractorNewUserStrategy.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/02/2017.
//
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class UserDataCollectorInteractorNewUserStrategy: UserDataCollectorInteractorStrategy {
  
  override func shouldShowEmailVerification(userData:DataPointList,
                                   userRequiredData:RequiredDataPointList) -> Bool {
    if let requiredEmailSpec = userRequiredData.getRequiredDataPointOf(type: .email), requiredEmailSpec.verificationRequired {
      return true
    }
    else {
      guard let phoneVerification = userData.phoneDataPoint.verification, phoneVerification.status == .passed else {
        return false
      }
//      guard phoneVerification.alternateCredentials?.count > 0 else {
//        return false
//      }
      if let emailVerification = userData.emailDataPoint.verification, emailVerification.status == .passed {
        return false
      }
      return true
    }
  }
  
  override func shouldShowBirthdateVerification(userData: DataPointList,
                                                userRequiredData: RequiredDataPointList) -> Bool {
    return false
  }
  
  override func shouldRecoverUserAccount(userData:DataPointList) -> Bool {
    if !config.allowUserLogin {
      return false
    }
    guard let phoneVerification = userData.phoneDataPoint.verification, phoneVerification.status == .passed else {
      return false
    }
    guard let emailVerification = userData.emailDataPoint.verification, emailVerification.status == .passed else {
      return false
    }
    return true
  }
  
  override func shouldUpdateUserData(_ userData:DataPointList, initialUserData:DataPointList) -> DataPointList? {
    return nil
  }
  
  override func shouldCreateNewUser(_ userData:DataPointList) -> Bool {
    return true
  }

}
