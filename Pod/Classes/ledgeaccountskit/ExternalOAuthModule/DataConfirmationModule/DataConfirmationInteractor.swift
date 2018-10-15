//
//  DataConfirmationInteractor.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//

import UIKit

class DataConfirmationInteractor: DataConfirmationInteractorProtocol {
  private let userData: DataPointList

  init(userData: DataPointList) {
    self.userData = userData
  }

  func provideUserData(completion: (_ userData: DataPointList) -> Void) {
    completion(userData)
  }
}
