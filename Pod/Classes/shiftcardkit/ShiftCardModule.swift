//
//  ShiftCardModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 02/18/2018.
//
//

import Foundation

@objc public enum ShiftCardModuleMode: Int {
  case standalone
  case embedded
}

open class ShiftCardModule: UIModule {

  var shiftCardSession: ShiftCardSession {
    return shiftSession.shiftCardSession
  }
  let mode: ShiftCardModuleMode
  let options: ShiftCardOptions?
  var welcomeScreenModule: ShowGenericMessageModule?
  var authModule: AuthModuleProtocol?
  var existingShiftCardModule: UIModuleProtocol?
  var newShiftCardModule: NewShiftCardModule?

  var contextConfiguration: ContextConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  var projectConfiguration: ProjectConfiguration {
    return contextConfiguration.projectConfiguration
  }
  var shiftCardConfiguration: ShiftCardConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  var userDataPoints: DataPointList

  public init(mode: ShiftCardModuleMode,
              initialUserData: DataPointList? = nil,
              merchantData: MerchantData? = nil,
              options: ShiftCardOptions? = nil) {
    if let initialUserData = initialUserData {
      self.userDataPoints = initialUserData.copy() as! DataPointList // swiftlint:disable:this force_cast
    }
    else {
      self.userDataPoints = DataPointList()
    }
    self.mode = mode
    self.options = options
    super.init(serviceLocator: ServiceLocator.shared)
    self.shiftSession.shiftCardSession = ShiftCardSession(shiftSession: self.shiftSession)
    if let merchantData = merchantData {
      shiftSession.merchantData = merchantData
    }
  }

  // MARK: - Module Initialization
  override public func close() {
    if self.shiftCardConfiguration.posMode == true {
      clearUserToken()
      NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }
    NotificationCenter.default.removeObserver(self, name: .UserTokenSessionExpiredNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UserTokenSessionClosedNotification, object: nil)
    super.close()
  }

  override public func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    // Store the passed-in options in the storage
    if let options = self.options {
      self.shiftCardSession.setShiftCardOptions(shiftCardOptions: options)
    }
    self.loadConfigurationFromServer { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
        return
      case .success:
        // Register to the session expired event
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveSessionExpiredEvent(_:)),
                                               name: .UserTokenSessionExpiredNotification,
                                               object: nil)
        // Register to the session closed event
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveSessionClosedEvent(_:)),
                                               name: .UserTokenSessionClosedNotification,
                                               object: nil)
        if self.shiftCardConfiguration.posMode == true {
          // POS Mode
          NotificationCenter.default.addObserver(self,
                                                 selector: #selector(self.didReceiveApplicationEnterBackground),
                                                 name: NSNotification.Name.UIApplicationDidEnterBackground,
                                                 object: nil)
          // Empty user data
          self.userDataPoints = DataPointList()
        }
        // Prepare the initial screen
        self.prepareInitialScreen(completion)
      }
    }
  }

  fileprivate func prepareInitialScreen(_ completion:@escaping Result<UIViewController, NSError>.Callback) {
    if self.projectConfiguration.welcomeScreenAction.status == .enabled {
      let welcomeScreenModule = self.buildWelcomeScreenModule()
      self.addChild(module: welcomeScreenModule, completion: completion)
    }
    else {
      guard self.shiftSession.currentUserToken() != nil else {
        // There's no user. Show the auth module
        self.showAuthModule(addChild: true, completion: completion)
        return
      }
      // There's a user. Check if he has already cards.
      self.showExistingOrNewCardModule(addChild: true, completion: completion)
    }
  }

  // MARK: - Welcome Screen Module Handling

  fileprivate func buildWelcomeScreenModule() -> ShowGenericMessageModule {
    let welcomeScreenModule = ShowGenericMessageModule(
      serviceLocator: serviceLocator,
      showGenericMessageAction: projectConfiguration.welcomeScreenAction)
    welcomeScreenModule.onWelcomeScreenContinue = { [weak self] module in
      guard let wself = self else {
        return
      }
      guard wself.shiftSession.currentUserToken() != nil else {
        // There's no user. Show the auth module
        wself.showAuthModule { _ in }
        return
      }
      // There's a user. Check if he has already cards.
      wself.showExistingOrNewCardModule { _ in }
    }
    welcomeScreenModule.onClose = { [weak self] module in
      self?.close()
    }
    return welcomeScreenModule
  }

  // MARK: - Auth Module Handling

  fileprivate func showAuthModule(addChild: Bool = false,
                                  completion: @escaping Result<UIViewController, NSError>.Callback) {
    // Prepare the current user's data
    let authModuleConfig = AuthModuleConfig(projectConfiguration: projectConfiguration)
    let authModule = serviceLocator.moduleLocator.authModule(authConfig: authModuleConfig,
                                                             initialUserData: userDataPoints)
    authModule.onBack = { [unowned self] module in
      self.popModule {
        self.authModule = nil
      }
    }
    authModule.onClose = { [unowned self] module in
      self.authModule = nil
      self.close()
    }
    authModule.onExistingUser = { [weak self] module, user in
      guard let wself = self else {
        return
      }
      wself.userDataPoints = user.userData.copy() as! DataPointList // swiftlint:disable:this force_cast
      // There's a user. Check if he has already cards.
      wself.showExistingOrNewCardModule { _ in
        wself.authModule = nil
      }
    }
    self.authModule = authModule
    if addChild {
      self.addChild(module: authModule, leftButtonMode: .close, completion: completion)
    }
    else {
      self.push(module: authModule, leftButtonMode: .close, completion: completion)
    }
  }

  // MARK: - Existing or new Card Flows

  fileprivate func showExistingOrNewCardModule(addChild: Bool = false,
                                               pushModule: Bool = false,
                                               completion: @escaping Result<UIViewController, NSError>.Callback) {
    showLoadingView()
    shiftCardSession.getCards(0, rows: 100) { [unowned self] result in
      self.hideLoadingView()
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let cards):
        let nonClosedCards = cards.filter { $0.state != .cancelled }
        if let card = nonClosedCards.first {
          self.showManageCardModule(card: card, addChild: addChild, pushModule: pushModule, completion: completion)
        }
        else {
          self.showNewCardModule(addChild: addChild, completion: completion)
        }
      }
    }
  }

  private func showManageCardModule(card: Card,
                                    addChild: Bool,
                                    pushModule: Bool,
                                    completion: @escaping Result<UIViewController, NSError>.Callback) {
    let existingCardModule = serviceLocator.moduleLocator.manageCardModule(card: card, mode: mode)
    existingCardModule.onClose = { [unowned self] _ in
      self.close()
    }
    existingCardModule.onBack = { [unowned self] _ in
      self.popModule {}
    }
    self.existingShiftCardModule = existingCardModule
    let leftButtonMode: UIViewControllerLeftButtonMode = self.mode == .standalone ? .none : .close
    if addChild {
      self.addChild(module: existingCardModule, leftButtonMode: leftButtonMode, completion: completion)
    }
    else {
      if pushModule {
        push(module: existingCardModule, animated: true, leftButtonMode: leftButtonMode, completion: completion)
      }
      else {
        present(module: existingCardModule, animated: true, leftButtonMode: leftButtonMode, completion: completion)
      }
    }
  }

  private func showNewCardModule(addChild: Bool, completion: @escaping Result<UIViewController, NSError>.Callback) {
    let newShiftCardModule = NewShiftCardModule(serviceLocator: self.serviceLocator,
                                                initialDataPoints: self.userDataPoints,
                                                mode: self.mode)
    newShiftCardModule.onClose = { [unowned self] _ in
      self.close()
    }
    newShiftCardModule.onBack = { [unowned self] _ in
      self.popModule {}
    }
    self.newShiftCardModule = newShiftCardModule
    if addChild {
      newShiftCardModule.onFinish = { [unowned self] module in
        self.showExistingOrNewCardModule { [unowned self] _ in
          self.remove(module: module) { [unowned self] in
            self.newShiftCardModule = nil
          }
        }
      }
      self.addChild(module: newShiftCardModule) { [unowned self] result in
        self.hideLoadingSpinner()
        completion(result)
      }
    }
    else {
      newShiftCardModule.onFinish = { module in
        self.showExistingOrNewCardModule(addChild: false, pushModule: true) { [unowned self] result in
          self.newShiftCardModule = nil
          completion(result)
        }
      }
      hideLoadingSpinner()
      push(module: newShiftCardModule) { result in
        completion(result)
      }
    }
  }

  // MARK: - Configuration HandlingApplication

  fileprivate func loadConfigurationFromServer(_ completion:@escaping Result<Void, NSError>.Callback) {
    shiftSession.contextConfiguration { [unowned self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success (let contextConfiguration):
        self.contextConfiguration = contextConfiguration
        self.shiftCardSession.shiftCardConfiguration(true) { [unowned self] result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let shiftCardConfiguration):
            self.shiftCardConfiguration = shiftCardConfiguration
            completion(.success(Void()))
          }
        }
      }
    }
  }

  // MARK: - Notification Handling

  @objc private func didReceiveSessionExpiredEvent(_ notification: Notification) {
    DispatchQueue.main.async {
      self.hideLoadingView()
      self.hideLoadingSpinner()
      UIAlertController.confirm(title: "error.transport.sessionExpired.title".podLocalized(),
                                message: "error.transport.sessionExpired".podLocalized(),
                                okTitle: "general.button.ok".podLocalized()) { _ in
                                  self.close()
      }
    }
  }

  @objc private func didReceiveSessionClosedEvent(_ notification: Notification) {
    self.hideLoadingView()
    self.hideLoadingSpinner()
    close()
  }

  @objc fileprivate func didReceiveApplicationEnterBackground() {
    clearUserToken()
  }

  fileprivate func clearUserToken() {
    ShiftPlatform.defaultManager().clearUserToken()
  }

}

extension ShiftSession {
  public func startCardFlow(from: UIViewController,
                            mode: ShiftCardModuleMode,
                            initialUserData: DataPointList? = nil,
                            options: ShiftCardOptions? = nil,
                            completion: @escaping (Result<UIModule, NSError>.Callback)) {
    self.contextConfiguration(false) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        let shiftCardModule = ShiftCardModule(mode: mode, initialUserData: initialUserData, options: options)
        self.initialModule = shiftCardModule
        shiftCardModule.onClose = { [unowned self] module in
          from.dismiss(animated: true) {}
          self.initialModule = nil
        }
        let uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration,
                                     fontCustomizationOptions: options?.fontCustomizationOptions)
        shiftCardModule.serviceLocator.uiConfig = uiConfig
        from.present(module: shiftCardModule, animated: true, leftButtonMode: .close, uiConfig: uiConfig) { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success:
            completion(.success(shiftCardModule))
          }
        }
      }
    }
  }

  @objc public func startCardFlow(from: UIViewController,
                                  mode: ShiftCardModuleMode,
                                  initialUserData: DataPointList?,
                                  options: ShiftCardOptions?,
                                  completion: @escaping (_ module: UIModule?, _ error: NSError?) -> Void) {
    startCardFlow(from: from, mode: mode, initialUserData: initialUserData, options: options) { result in
      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let module):
        completion(module, nil)
      }
    }
  }
}
