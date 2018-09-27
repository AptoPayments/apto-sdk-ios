//
//  AuthModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 12/12/2017.
//

import UIKit

protocol AuthRouterProtocol: class {
  func close()
  func back()
  func presentPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>,
                                completion: (Result<Verification, NSError>.Callback)?)
  func presentEmailVerification(verificationType: VerificationParams<Email, Verification>,
                                completion: (Result<Verification, NSError>.Callback)?)
  func presentBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>,
                                    completion: (Result<Verification, NSError>.Callback)?)
  func returnExistingUser(_ user: ShiftUser)
}

protocol AuthInteractorProtocol {
  func provideAuthData()
  func nextTapped()
  func phoneVerificationSucceeded(_ verification: Verification)
  func phoneVerificationFailed()
  func emailVerificationSucceeded(_ verification: Verification)
  func emailVerificationFailed()
  func birthdateVerificationSucceeded(_ verification: Verification)
  func birthdateVerificationFailed()
}

protocol AuthViewProtocol: ViewControllerProtocol {
  func show(fields: [FormRowView])
  func update(progress: Float)
}

protocol AuthDataReceiver: class {
  func set(_ userData: DataPointList,
           primaryCredentialType: DataPointType,
           secondaryCredentialType: DataPointType)
  func show(error: NSError)
  func showPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>)
  func showEmailVerification(verificationType: VerificationParams<Email, Verification>)
  func showBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>)
  func returnExistingUser(_ user: ShiftUser)
}

protocol AuthEventHandler: class {
  func viewLoaded()
  func nextTapped()
  func closeTapped()
}

protocol AuthPresenterProtocol: AuthDataReceiver, AuthEventHandler {
  // swiftlint:disable implicitly_unwrapped_optional
  var viewController: AuthViewProtocol! { get set }
  var interactor: AuthInteractorProtocol! { get set }
  var router: AuthRouterProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
}

protocol AuthModuleProtocol: UIModuleProtocol, AuthRouterProtocol {
  var onExistingUser: ((_ authModule: AuthModule, _ user: ShiftUser) -> Void)? { get set }
}

class AuthModule: UIModule, AuthModuleProtocol {
  private let config: AuthModuleConfig
  private let initialUserData: DataPointList

  open var onExistingUser: ((_ authModule: AuthModule, _ user: ShiftUser) -> Void)?

  fileprivate var verifyPhoneModule: VerifyPhoneModuleProtocol?
  fileprivate var verifyEmailModule: VerifyEmailModuleProtocol?
  fileprivate var verifyBirthDateModule: VerifyBirthDateModuleProtocol?
  fileprivate var authPresenter: AuthPresenterProtocol?

  // MARK: - Module Initialization

  init(serviceLocator: ServiceLocatorProtocol,
       config: AuthModuleConfig,
       uiConfig: ShiftUIConfig,
       initialUserData: DataPointList) {
    self.config = config
    self.initialUserData = initialUserData
    super.init(serviceLocator: serviceLocator)
    self.uiConfig = uiConfig
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = self.buildAuthViewController(initialUserData,
                                                      uiConfig: uiConfig!, // swiftlint:disable:this force_unwrapping
                                                      config: config)
    self.addChild(viewController: viewController, completion: completion)
  }

  // MARK: - Auth View Controller Handling

  fileprivate func buildAuthViewController(_ initialUserData: DataPointList,
                                           uiConfig: ShiftUIConfig,
                                           config: AuthModuleConfig) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.authPresenter(authConfig: config, uiConfig: uiConfig)
    let interactor = serviceLocator.interactorLocator.authInteractor(shiftSession: shiftSession,
                                                                     initialUserData: initialUserData,
                                                                     authConfig: config,
                                                                     dataReceiver: presenter)
    let viewController = serviceLocator.viewLocator.authView(uiConfig: uiConfig, eventHandler: presenter)

    presenter.viewController = viewController
    presenter.interactor = interactor
    presenter.router = self
    authPresenter = presenter

    return viewController
  }

  // MARK: - AuthRouterProtocol protocol

  func returnExistingUser(_ user: ShiftUser) {
    onExistingUser?(self, user)
  }

  func presentPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>,
                                completion: (Result<Verification, NSError>.Callback)?) {
    let verifyPhoneModule = serviceLocator.moduleLocator.verifyPhoneModule(verificationType: verificationType)
    verifyPhoneModule.onClose = { [weak self] module in
      self?.dismissModule {
        self?.verifyPhoneModule = nil
      }
    }
    verifyPhoneModule.onVerificationPassed = { [weak self] module, verification in
      self?.dismissModule {
        self?.verifyPhoneModule = nil
        completion?(.success(verification))
      }
    }
    self.verifyPhoneModule = verifyPhoneModule
    self.present(module: verifyPhoneModule) { _ in }
  }

  func presentEmailVerification(verificationType: VerificationParams<Email, Verification>,
                                completion: (Result<Verification, NSError>.Callback)?) {
    let verifyEmailModule = serviceLocator.moduleLocator.verifyEmailModule(verificationType: verificationType)
    verifyEmailModule.onClose = { [weak self] _ in
      self?.dismissModule {
        self?.verifyEmailModule = nil
      }
    }
    verifyEmailModule.onVerificationPassed = { [weak self] _, verification in
      self?.dismissModule {
        self?.verifyEmailModule = nil
        completion?(.success(verification))
      }
    }
    self.verifyEmailModule = verifyEmailModule
    self.present(module: verifyEmailModule) { _ in }
  }

  func presentBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>,
                                    completion: (Result<Verification, NSError>.Callback)?) {
    let verifyBirthDateModule = serviceLocator.moduleLocator.verifyBirthDateModule(verificationType: verificationType)
    verifyBirthDateModule.onClose = { [weak self] module in
      self?.dismissModule {
        self?.verifyBirthDateModule = nil
      }
    }
    verifyBirthDateModule.onVerificationPassed = { [weak self] module, verification in
      self?.dismissModule {
        self?.verifyBirthDateModule = nil
        completion?(.success(verification))
      }
    }
    self.verifyBirthDateModule = verifyBirthDateModule
    self.present(module: verifyBirthDateModule) { _ in }
  }

}
