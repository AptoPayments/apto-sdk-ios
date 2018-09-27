//
//  PhoneVerificatorWireframe.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 12/10/2016.
//
//

import UIKit

protocol VerifyPhoneModuleProtocol: UIModuleProtocol {
  var onVerificationPassed: ((_ verifyPhoneModule: VerifyPhoneModule,
                              _ verification: Verification) -> Void)? { get set }
}

class VerifyPhoneModule: UIModule, VerifyPhoneModuleProtocol {
  private let verificationType: VerificationParams<PhoneNumber, Verification>
  private var presenter: VerifyPhonePresenter?
  open var onVerificationPassed: ((_ verifyPhoneModule: VerifyPhoneModule, _ verification: Verification) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol,
       verificationType: VerificationParams<PhoneNumber, Verification>) {
    self.verificationType = verificationType
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        let uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        self.uiConfig = uiConfig
        let presenter = VerifyPhonePresenter()
        let interactor = VerifyPhoneInteractor(session: self.shiftSession,
                                               verificationType: self.verificationType,
                                               dataReceiver: presenter)
        presenter.interactor = interactor
        presenter.router = self
        let viewController = PINVerificationViewController(uiConfig: uiConfig, eventHandler: presenter)
        presenter.view = viewController
        self.addChild(viewController: viewController, completion: completion)
        self.presenter = presenter
      }
    }
  }
}

extension VerifyPhoneModule: VerifyPhoneRouterProtocol {
  func closeTappedInVerifyPhone() {
    self.close()
  }

  func phoneVerificationPassed(verification: Verification) {
    self.onVerificationPassed?(self, verification)
  }
}
