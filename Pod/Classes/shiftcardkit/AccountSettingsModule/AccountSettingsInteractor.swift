//
//  ShiftCardSettingsInteractor.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

import Foundation

class AccountSettingsInteractor: AccountSettingsInteractorProtocol {
  private let shiftSession: ShiftSession

  init(shiftSession: ShiftSession) {
    self.shiftSession = shiftSession
  }

  func logoutCurrentUser() {
    shiftSession.logout()
  }
}
