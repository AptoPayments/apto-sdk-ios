//
//  UserDataCollectorModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 14/10/2016.
//
//

import Foundation

public enum UserDataCollectorFinalStepMode {
  case updateUser
  case continueFlow
}

class UserDataCollectorModule: UIModule {
  private let userRequiredData: RequiredDataPointList
  private let disclaimers: [Content]
  private let mode: UserDataCollectorFinalStepMode
  private let backButtonMode: UIViewControllerLeftButtonMode
  private let finalStepTitle: String
  private let finalStepSubtitle: String
  private let finalStepCallToAction: CallToAction
  private var presenter: UserDataCollectorPresenter?

  // swiftlint:disable implicitly_unwrapped_optional
  var initialUserData: DataPointList!
  var config: UserDataCollectorConfig!
  // swiftlint:enable implicitly_unwrapped_optional

  open var onUserDataCollected: ((_ userDataCollectorModule: UserDataCollectorModule, _ user: ShiftUser) -> Void)?

  fileprivate var verifyPhoneModule: VerifyPhoneModule?
  fileprivate var verifyEmailModule: VerifyEmailModule?
  fileprivate var verifyBirthDateModule: VerifyBirthDateModule?

  init(serviceLocator: ServiceLocatorProtocol,
       userRequiredData: RequiredDataPointList,
       mode: UserDataCollectorFinalStepMode,
       backButtonMode: UIViewControllerLeftButtonMode,
       finalStepTitle: String,
       finalStepSubtitle: String,
       finalStepCallToAction: CallToAction,
       disclaimers: [Content] = []) {
    self.userRequiredData = userRequiredData
    self.disclaimers = disclaimers
    self.mode = mode
    self.backButtonMode = backButtonMode
    self.finalStepTitle = finalStepTitle
    self.finalStepSubtitle = finalStepSubtitle
    self.finalStepCallToAction = finalStepCallToAction

    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure (let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.shiftSession.currentUser { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let user):
            self.initializeConfig(contextConfiguration: contextConfiguration)
            self.initialUserData = user.userData
            let uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
            self.uiConfig = uiConfig
            let viewController = self.buildUserDataCollectorViewController(self.initialUserData,
                                                                           uiConfig: uiConfig,
                                                                           config: self.config)
            self.addChild(viewController: viewController, completion: completion)
          }
        }
      }
    }
  }

  fileprivate func buildUserDataCollectorViewController(_ initialUserData: DataPointList,
                                                        uiConfig: ShiftUIConfig,
                                                        config: UserDataCollectorConfig) -> UIViewController {
    let presenter = UserDataCollectorPresenter(config: config, uiConfig: uiConfig, shiftSession: shiftSession)
    let interactor = UserDataCollectorInteractor(session: self.shiftSession,
                                                 initialUserData: initialUserData,
                                                 config: self.config,
                                                 dataReceiver: presenter)

    let viewController = UserDataCollectorViewController(uiConfiguration: uiConfig, eventHandler: presenter)
    presenter.viewController = viewController
    presenter.interactor = interactor
    presenter.router = self
    self.presenter = presenter
    return viewController
  }

  private func initializeConfig(contextConfiguration: ContextConfiguration) {
    config = UserDataCollectorConfig(contextConfiguration: contextConfiguration,
                                     mode: mode,
                                     backButtonMode: backButtonMode,
                                     finalStepTitle: finalStepTitle,
                                     finalStepSubtitle: finalStepSubtitle,
                                     finalStepCallToAction: finalStepCallToAction,
                                     userRequiredData: userRequiredData,
                                     disclaimers: disclaimers)
  }
}

extension UserDataCollectorModule: UserDataCollectorRouterProtocol {
  func presentPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>,
                                modally: Bool?,
                                completion: Result<Verification, NSError>.Callback?) {
    let verifyPhoneModule = VerifyPhoneModule(serviceLocator: serviceLocator, verificationType: verificationType)
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
                                modally: Bool?,
                                completion: Result<Verification, NSError>.Callback?) {
    let verifyEmailModule = VerifyEmailModule(serviceLocator: serviceLocator, verificationType: verificationType)
    verifyEmailModule.onClose = { [weak self] module in
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
                                    modally: Bool?,
                                    completion: (Result<Verification, NSError>.Callback)?) {
    let verifyBirthDateModule = VerifyBirthDateModule(serviceLocator: serviceLocator,
                                                      verificationType: verificationType)
    verifyBirthDateModule.onClose = { [weak self] _ in
      self?.dismissModule {
        self?.verifyBirthDateModule = nil
      }
    }
    verifyBirthDateModule.onVerificationPassed = { [weak self] _, verification in
      self?.dismissModule {
        self?.verifyBirthDateModule = nil
        completion?(.success(verification))
      }
    }
    self.verifyBirthDateModule = verifyBirthDateModule
    self.present(module: verifyBirthDateModule) { _ in }
  }

  func userDataCollected(_ user: ShiftUser) {
    onUserDataCollected?(self, user)
    onFinish?(self)
  }
}
