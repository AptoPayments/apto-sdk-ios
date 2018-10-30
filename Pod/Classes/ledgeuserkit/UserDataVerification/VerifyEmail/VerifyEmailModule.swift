//
//  VerifyEmailModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 13/10/2016.
//
//

import UIKit

protocol VerifyEmailRouterProtocol: class {
  func closeTappedInVerifyEmail()
  func nextTappedInVerifyEmailWith(verification:Verification)
}

protocol VerifyEmailModuleProtocol: UIModuleProtocol {
  var onVerificationPassed: ((_ verifyPhoneModule: VerifyEmailModule,
                              _ verification: Verification) -> Void)? { get set }
}

class VerifyEmailModule: UIModule, VerifyEmailModuleProtocol {
  var presenter: VerifyEmailPresenter?
  let verificationType: VerificationParams<Email, Verification>

  open var onVerificationPassed: ((_ verifyPhoneModule: VerifyEmailModule, _ verification: Verification) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol, verificationType: VerificationParams<Email, Verification>) {
    self.verificationType = verificationType
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let presenter = VerifyEmailPresenter()
    let interactor = VerifyEmailInteractor(session: shiftSession,
                                           verificationType: verificationType,
                                           dataReceiver: presenter)
    presenter.interactor = interactor
    presenter.router = self
    let viewController = PINVerificationViewController(uiConfig: uiConfig, eventHandler: presenter)
    presenter.view = viewController
    addChild(viewController: viewController, completion: completion)
    self.presenter = presenter
  }
}

extension VerifyEmailModule: VerifyEmailRouterProtocol {
  func closeTappedInVerifyEmail() {
    close()
  }

  func nextTappedInVerifyEmailWith(verification: Verification) {
    onVerificationPassed?(self, verification)
  }
}
