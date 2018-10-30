//
//  VerifyBirthDateModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 12/10/2016.
//
//

import UIKit

protocol VerifyBirthDateModuleProtocol: UIModuleProtocol {
  var onVerificationPassed: ((_ verifyBirthDateModule: VerifyBirthDateModule,
                              _ verification: Verification) -> Void)? { get set }
}

class VerifyBirthDateModule: UIModule, VerifyBirthDateModuleProtocol {
  private let verificationType: VerificationParams<BirthDate, Verification>
  private var presenter: VerifyBirthDatePresenter?

  open var onVerificationPassed: ((_ verifyBirthDateModule: VerifyBirthDateModule,
                                   _ verification: Verification) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol, verificationType: VerificationParams<BirthDate, Verification>) {
    self.verificationType = verificationType
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let presenter = VerifyBirthDatePresenter()
    let interactor = VerifyBirthDateInteractor(session: shiftSession,
                                               verificationType: verificationType,
                                               dataReceiver: presenter)
    presenter.interactor = interactor
    presenter.router = self
    let viewController = VerifyBirthDateViewController(uiConfig: uiConfig)
    viewController.eventHandler = presenter
    presenter.view = viewController
    addChild(viewController: viewController, completion: completion)
    self.presenter = presenter
  }
}

extension VerifyBirthDateModule: VerifyBirthDateRouterProtocol {
  func closeTappedInVerifyBirthDate() {
    self.close()
  }

  func birthDateVerificationPassed(verification: Verification) {
    self.onVerificationPassed?(self, verification)
  }
}
