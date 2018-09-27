//
//  UserDataCollectorInteractorExistingUserStrategy.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/02/2017.
//
//

import Foundation

class UserDataCollectorInteractorExistingUserStrategy: UserDataCollectorInteractorStrategy {
  
  override func shouldShowEmailVerification(userData: DataPointList,
                                   userRequiredData: RequiredDataPointList) -> Bool {
    return false
  }
  
  override func shouldShowBirthdateVerification(userData: DataPointList,
                                       userRequiredData: RequiredDataPointList) -> Bool {
    return false
  }

  override func shouldRecoverUserAccount(userData: DataPointList) -> Bool {
    return false
  }
  
  override func shouldUpdateUserData(_ userData: DataPointList,
                            initialUserData: DataPointList) -> DataPointList? {
    let differences = initialUserData.modifiedDataPoints(compareWith: userData)
    if differences.dataPoints.count > 0 {
      return differences
    }
    return nil
  }
  
  override func shouldCreateNewUser(_ userData: DataPointList) -> Bool {
    return false
  }

}
