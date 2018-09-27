//
//  AccountSettingsPresenter.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

import Foundation

class AccountSettingsPresenter: AccountSettingsPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: AccountSettingsViewProtocol!
  var interactor: AccountSettingsInteractorProtocol!
  weak var router: AccountSettingsRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional

  func viewLoaded() {
  }

  func previousTapped() {
    router.backFromAccountSettings()
  }

  func closeTapped() {
    router.closeFromAccountSettings()
  }

  func logoutTapped() {
    interactor.logoutCurrentUser()
  }

  func contactTapped() {
    router.contactTappedInAccountSettings()
  }
}
