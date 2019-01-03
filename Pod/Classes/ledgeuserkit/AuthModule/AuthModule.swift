//
//  AuthModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 12/12/2017.
//

import UIKit

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
       initialUserData: DataPointList) {
    self.config = config
    self.initialUserData = initialUserData
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildAuthViewController(initialUserData, uiConfig: uiConfig, config: config)
    addChild(viewController: viewController, completion: completion)
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
