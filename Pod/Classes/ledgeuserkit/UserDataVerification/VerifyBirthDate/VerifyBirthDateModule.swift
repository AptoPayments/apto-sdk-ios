//
//  VerifyBirthDateModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 12/10/2016.
//
//

import UIKit

class VerifyBirthDateModule: UIModule, VerifyBirthDateModuleProtocol {
  private let verificationType: VerificationParams<BirthDate, Verification>
  private var presenter: VerifyBirthDatePresenterProtocol?

  open var onVerificationPassed: ((_ verifyBirthDateModule: VerifyBirthDateModule,
                                   _ verification: Verification) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol, verificationType: VerificationParams<BirthDate, Verification>) {
    self.verificationType = verificationType
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let presenter = serviceLocator.presenterLocator.verifyBirthDatePresenter()
    let interactor = serviceLocator.interactorLocator.verifyBirthDateInteractor(verificationType: verificationType,
                                                                                dataReceiver: presenter)
    presenter.interactor = interactor
    presenter.router = self
    let viewController = serviceLocator.viewLocator.verifyBirthDateView(presenter: presenter)
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
