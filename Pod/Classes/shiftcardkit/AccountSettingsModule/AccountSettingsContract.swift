//
//  AccountSettingsContract.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

protocol AccountSettingsRouterProtocol: class {
  func backFromAccountSettings()
  func closeFromAccountSettings()
  func contactTappedInAccountSettings()
}

typealias AccountSettingsViewProtocol = ShiftViewController

protocol AccountSettingsInteractorProtocol {
  func logoutCurrentUser()
}

protocol AccountSettingsPresenterProtocol: class {
  var view: AccountSettingsViewProtocol! { get set }
  var interactor: AccountSettingsInteractorProtocol! { get set }
  var router: AccountSettingsRouterProtocol! { get set }

  func viewLoaded()
  func previousTapped()
  func closeTapped()
  func logoutTapped()
  func contactTapped()
}
