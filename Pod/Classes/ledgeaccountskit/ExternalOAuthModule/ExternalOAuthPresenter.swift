//
//  ExternalOAuthPresenter.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation

class ExternalOAuthPresenter: ExternalOAuthPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: ExternalOAuthInteractorProtocol!
  weak var router: ExternalOAuthRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel = ExternalOAuthViewModel()

  init(config: ExternalOAuthModuleConfig) {
    viewModel.title.next(config.title)
    viewModel.imageName.next(config.imageName)
    viewModel.provider.next(config.provider)
    viewModel.accessDescription.next(config.accessDescription)
    viewModel.callToActionTitle.next(config.callToActionTitle)
    viewModel.description.next(config.description)
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
