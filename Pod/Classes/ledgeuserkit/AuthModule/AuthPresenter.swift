//
//  AuthPresenter.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/12/2017.
//

import UIKit
import ReactiveKit

class AuthPresenter: AuthPresenterProtocol {
  private let disposeBag = DisposeBag()
  private let config: AuthModuleConfig
  private let uiConfig: ShiftUIConfig

  // swiftlint:disable implicitly_unwrapped_optional
  var viewController: AuthViewProtocol!
  var interactor: AuthInteractorProtocol!
  weak var router: AuthRouterProtocol!
  private var primaryCredentialStep: DataCollectorStepProtocol!
  // swiftlint:enable implicitly_unwrapped_optional

  // MARK: Initialization

  init(config: AuthModuleConfig, uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
    self.config = config
  }

  // MARK: AuthEventHandler protocol

  func viewLoaded() {
    self.interactor.provideAuthData()
  }

  func set(_ userData: DataPointList,
           primaryCredentialType: DataPointType,
           secondaryCredentialType: DataPointType) {
    switch primaryCredentialType {
    case .phoneNumber:
      primaryCredentialStep = AuthPhoneStep(userData: userData,
                                            allowedCountries: config.allowedCountries,
                                            uiConfig: uiConfig)
    case .email:
      primaryCredentialStep = AuthEmailStep(userData: userData, uiConfig: uiConfig)
    default:
      // TODO: Support BirthDate as a primary credential
      break
    }
    viewController.show(fields: primaryCredentialStep.rows)
    viewController.set(title: primaryCredentialStep.title)
    viewController.showNavCancelButton(uiConfig.iconTertiaryColor)
    viewController.showNavNextButton(title: "auth-presenter.next".podLocalized(), tintColor: uiConfig.iconTertiaryColor)
    self.viewController.update(progress: 10)
    primaryCredentialStep.valid.distinct().observeNext { [weak self] validStep in
      if validStep { self?.viewController.activateNavNextButton(self?.uiConfig.iconTertiaryColor) }
      else { self?.viewController.deactivateNavNextButton(self?.uiConfig.disabledTextTopBarColor) }
    }.dispose(in: disposeBag)
  }

  func nextTapped() {
    interactor.nextTapped()
  }

  func closeTapped() {
    router.close()
  }

  // MARK: - AuthDataReceiver protocol

  func showPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>) {
    router.presentPhoneVerification(verificationType: verificationType) { [weak self] result in
      switch result {
      case .failure:
        self?.interactor.phoneVerificationFailed()
      case .success(let verification):
        self?.interactor.phoneVerificationSucceeded(verification)
      }
    }
  }

  func showEmailVerification(verificationType: VerificationParams<Email, Verification>) {
    router.presentEmailVerification(verificationType: verificationType) { [weak self] result in
      switch result {
      case .failure:
        self?.interactor.emailVerificationFailed()
      case .success(let verification):
        self?.interactor.emailVerificationSucceeded(verification)
      }
    }
  }

  func showBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>) {
    router.presentBirthdateVerification(verificationType: verificationType) { [weak self] result in
      switch result {
      case .failure:
        self?.interactor.birthdateVerificationFailed()
      case .success(let verification):
        self?.interactor.birthdateVerificationSucceeded(verification)
      }
    }
  }

  func show(error: NSError) {
    viewController.show(error: error)
  }

  func returnExistingUser(_ user: ShiftUser) {
    router.returnExistingUser(user)
  }

}
