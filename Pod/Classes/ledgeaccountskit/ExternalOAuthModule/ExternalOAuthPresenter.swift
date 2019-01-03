//
//  ExternalOAuthPresenter.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation

class ExternalOAuthPresenter: ExternalOAuthPresenterProtocol {
  let config: ExternalOAuthModuleConfig
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: ExternalOAuthInteractorProtocol!
  weak var router: ExternalOAuthRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel = ExternalOAuthViewModel()

  init(config: ExternalOAuthModuleConfig) {
    self.config = config
  }

  func viewLoaded() {
    viewModel.title.next(config.title)
    viewModel.allowedBalanceTypes.next(config.allowedBalanceTypes)
  }

  func balanceTypeTapped(_ balanceType: AllowedBalanceType) {
    interactor.balanceTypeSelected(balanceType)
  }

  func backTapped() {
    router.backInExternalOAuth(true)
  }

  func show(error: NSError) {
    viewModel.error.next(error)
  }

  func show(url: URL) {
    router.show(url: url) { [weak self] in
      self?.router.showLoadingSpinner()
      self?.interactor.custodianAuthenticationSucceed()
    }
  }

  func custodianSelected(_ custodian: Custodian) {
    router.hideLoadingSpinner()
    router.oauthSucceeded(custodian)
  }
}
