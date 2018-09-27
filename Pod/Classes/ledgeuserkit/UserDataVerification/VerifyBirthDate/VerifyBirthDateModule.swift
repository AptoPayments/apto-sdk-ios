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
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        let config = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        self.uiConfig = config
        let presenter = VerifyBirthDatePresenter()
        let interactor = VerifyBirthDateInteractor(session: self.shiftSession,
                                                   verificationType: self.verificationType,
                                                   dataReceiver: presenter)
        presenter.interactor = interactor
        presenter.router = self
        let viewController = VerifyBirthDateViewController(uiConfig: config)
        viewController.eventHandler = presenter
        presenter.view = viewController
        self.addChild(viewController: viewController, completion: completion)
        self.presenter = presenter
      }
    }
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
