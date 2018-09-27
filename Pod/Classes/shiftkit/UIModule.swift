//
//  UIModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 29/03/2018.
//

import Foundation

open class UIModule: NSObject, UIModuleProtocol {

  // MARK: - Private Attributes

  // View Controllers and modules shown in the current module
  fileprivate var viewControllers: [UIViewController] = []
  fileprivate var uiModules: [UIModule] = []

  // Parent module (if any)
  fileprivate weak var parentUIModule: UIModule?

  // View Controller and Module presented modally from the current module
  fileprivate var presentedViewController: UIViewController? = nil
  fileprivate var presentedModule: UIModuleProtocol? = nil

  // Current module navigation controller
  fileprivate var _navigationViewController: UINavigationController?
  var navigationController: UINavigationController? {
    get {
      if let nc = self._navigationViewController {
        return nc
      }
      return parentUIModule?.navigationController
    }
    set (nc) {
      self._navigationViewController = nc
    }
  }

  // UI Configuration
  public var uiConfig: ShiftUIConfig?

  // Service locator
  let serviceLocator: ServiceLocatorProtocol

  // Session
  public var shiftSession: ShiftSession {
    return serviceLocator.session
  }

  // Callbacks
  open var onClose:((_ module: UIModuleProtocol)->Void)?
  open var onBack:((_ module: UIModuleProtocol)->Void)?
  open var onNext:((_ module: UIModuleProtocol)->Void)?
  open var onFinish: ((_ module: UIModuleProtocol) -> Void)?

  // init
  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator

    super.init()
  }

  // MARK: - Module Lifecycle

  public func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    // Implement in subclasses
    viewControllers = [UIViewController()]
    completion(.success(viewControllers.first!))
  }

  public func close() {
    onClose?(self)
  }

  public func back() {
    onBack?(self)
  }

  public func next() {
    onNext?(self)
  }

  // MARK: - Methods to add or remove content in the current module

  public func push(viewController: UIViewController,
                   animated: Bool? = true,
                   leftButtonMode : UIViewControllerLeftButtonMode? = .back,
                   completion: @escaping (() -> Void)) {
    guard let uiConfig = self.uiConfig else {
      return
    }
    viewController.configureLeftNavButton(mode: leftButtonMode!, uiConfig: uiConfig)
    navigationController?.pushViewController(viewController, animated: animated!) { [ weak self] in
      self?.viewControllers.append(viewController)
      completion()
    }
  }

  public func popViewController(animated: Bool? = true, completion: @escaping (() -> Void)) {
    navigationController?.popViewController(animated!) { [ weak self] in
      self?.viewControllers.removeLast()
      completion()
    }
  }

  public func present(viewController: UIViewController, animated: Bool? = true, completion: @escaping (() -> Void)) {
    navigationController?.viewControllers.last?.present(viewController, animated: animated!) { [weak self] in
      self?.presentedViewController = viewController
      completion()
    }
  }

  public func push(module: UIModuleProtocol,
                   animated: Bool? = true,
                   leftButtonMode : UIViewControllerLeftButtonMode? = .back,
                   completion: @escaping Result<UIViewController, NSError>.Callback) {
    guard let module = module as? UIModule else {
      fatalError("module must inherit from UIModule")
    }
    module.initialize { [weak self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let initialViewController):
        module.parentUIModule = self
        self?.uiModules.append(module)
        self?.push(viewController: initialViewController, animated: animated, leftButtonMode: leftButtonMode!) {
          completion(.success(initialViewController))
        }
      }
    }
  }

  public func popModule(animated: Bool? = true, completion: @escaping (() -> Void)) {
    if uiModules.count <= 1 && viewControllers.count == 0 {
      // Last child module to pop. Pop the current module instead
      self.back()
      completion()
    }
    else {
      if let module = uiModules.last {
        module.removeFromNavigationController(animated: animated!) { [weak self] in
          self?.uiModules.removeLast()
          completion()
        }
      }
      else {
        completion()
      }
    }
  }

  public func remove(module: UIModuleProtocol, completion: @escaping (() -> Void)) {
    guard let module = module as? UIModule else {
      fatalError("module must inherit from UIModule")
    }
    module.removeFromNavigationController(animated: false) { [weak self] in
      guard let wself = self else {
        return
      }
      wself.uiModules = wself.uiModules.filter { $0 !== module }
      completion()
    }
  }

  public func present(module: UIModuleProtocol, animated: Bool? = true, leftButtonMode : UIViewControllerLeftButtonMode? = .close, completion: @escaping Result<UIViewController, NSError>.Callback) {
    guard let module = module as? UIModule else {
      fatalError("module must inherit from UIModule")
    }
    module.initialize { [weak self] result in
      guard let wself = self, let uiConfig = self?.uiConfig else {
        return
      }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let initialViewController):
        let newNavigationController = UINavigationController(rootViewController: initialViewController)
        module.navigationController = newNavigationController
        initialViewController.configureLeftNavButton(mode: leftButtonMode!, uiConfig: uiConfig)
        wself.navigationController?.viewControllers.last?.present(newNavigationController, animated: animated!) { [weak self] in
          self?.presentedModule = module
          completion(.success(initialViewController))
        }
      }
    }
  }

  public func dismissViewController(animated: Bool? = true, completion: @escaping (() -> Void)) {
    navigationController?.viewControllers.last?.dismiss(animated: animated!, completion: completion)
  }

  public func dismissModule(animated: Bool? = true, completion: @escaping (() -> Void)) {
    navigationController?.viewControllers.last?.dismiss(animated: animated!, completion: completion)
  }

  public func addChild(module: UIModuleProtocol,
                       leftButtonMode: UIViewControllerLeftButtonMode? = .back,
                       completion: @escaping Result<UIViewController, NSError>.Callback) {
    guard let module = module as? UIModule else {
      fatalError("module must inherit from UIModule")
    }
    module.initialize { [weak self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let initialViewController):
        module.parentUIModule = self
        self?.uiModules.append(module)
        if let uiConfig = self?.uiConfig {
          initialViewController.configureLeftNavButton(mode: leftButtonMode!, uiConfig: uiConfig)
        }
        completion(.success(initialViewController))
      }
    }
  }

  public func addChild(viewController: UIViewController,
                       leftButtonMode: UIViewControllerLeftButtonMode? = .back,
                       completion: @escaping Result<UIViewController, NSError>.Callback) {
    if let uiConfig = self.uiConfig {
      viewController.configureLeftNavButton(mode: leftButtonMode!, uiConfig: uiConfig)
    }
    viewControllers.append(viewController)
    completion(.success(viewController))
  }

  // MARK: - Useful (helper) functions

  public func showLoadingSpinner(position: SubviewPosition = .center) {
    UIApplication.topViewController()?.showLoadingSpinner(tintColor: uiConfig?.uiPrimaryColor ?? .darkGray,
                                                          position: position)
  }

  public func hideLoadingSpinner() {
    UIApplication.topViewController()?.hideLoadingSpinner()
  }

  public func show(error: Error) {
    UIApplication.topViewController()?.show(error: error)
  }

  // MARK: - Private Methods to remove the current module from navigation controller

  fileprivate func removeFromNavigationController(animated:Bool, completion: @escaping (() -> Void)) {

    removeChildModules(animated: animated) { [weak self] in
      if !animated {
        self?.removeViewControllers()
        completion()
      }
      else {
        guard let viewControllers = self?.viewControllers, viewControllers.count > 0 else {
          completion()
          return
        }
        self?.removeViewControllersTail()
        guard let navigationController = self?.navigationController else {
          completion()
          return
        }
        navigationController.popViewController(animated, completion: completion)
      }
    }

  }

  fileprivate func removeViewControllers() {
    guard let navigationController = self.navigationController else {
      return
    }
    let filteredViewControllers = navigationController.viewControllers.filter { !self.viewControllers.contains($0) }
    navigationController.setViewControllers(filteredViewControllers, animated: false)
    self.viewControllers = []
  }

  fileprivate func removeViewControllersTail() {
    guard let navigationController = self.navigationController, self.viewControllers.count > 1 else {
      return
    }
    var viewControllersTail = self.viewControllers
    let initialViewController = viewControllersTail.remove(at: 0)
    let filteredViewControllers = navigationController.viewControllers.filter { !viewControllersTail.contains($0) }
    navigationController.setViewControllers(filteredViewControllers, animated: false)
    self.viewControllers = [initialViewController]
  }

  fileprivate func removeChildModules(animated: Bool, completion: @escaping (() -> Void)) {
    let myGroup = DispatchGroup()
    for childModule in uiModules {
      myGroup.enter()
      childModule.removeFromNavigationController(animated: animated) {
        myGroup.leave()
      }
    }
    myGroup.notify(queue: .main) {
      completion()
    }
  }

  fileprivate var navigationBarBackgroundImage: UIImage? = nil
  fileprivate var navigationBarShadowImage: UIImage? = nil
  fileprivate var navigationBarIsTranslucent: Bool = false
  fileprivate var navigationBarViewBackgroundColor: UIColor? = nil
  fileprivate var navigationBarBackgroundColor: UIColor? = nil
  fileprivate var navigationBarTransparentStyleApplied = false

  func makeNavigationBarTransparent() {
    if let navigationController = self.navigationController {
      self.navigationBarBackgroundImage = navigationController.navigationBar.backgroundImage(for: UIBarMetrics.default)
      self.navigationBarShadowImage = navigationController.navigationBar.shadowImage
      self.navigationBarIsTranslucent = navigationController.navigationBar.isTranslucent
      self.navigationBarViewBackgroundColor = navigationController.view.backgroundColor
      self.navigationBarBackgroundColor = navigationController.navigationBar.backgroundColor
      self.navigationBarTransparentStyleApplied = true
      navigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
      navigationController.navigationBar.shadowImage = UIImage()
      navigationController.navigationBar.isTranslucent = true
      navigationController.view.backgroundColor = .clear
      navigationController.navigationBar.backgroundColor = .clear
    }
  }

  func restoreNavigationBarFromTransparentState() {
    if let navigationController = self.navigationController, self.navigationBarTransparentStyleApplied == true {
      navigationController.navigationBar.setBackgroundImage(self.navigationBarBackgroundImage, for: UIBarMetrics.default)
      navigationController.navigationBar.shadowImage = self.navigationBarShadowImage
      navigationController.navigationBar.isTranslucent = self.navigationBarIsTranslucent
      navigationController.view.backgroundColor = self.navigationBarViewBackgroundColor
      navigationController.navigationBar.backgroundColor = self.navigationBarBackgroundColor
    }
  }

}

// MARK: - Smooth push / pop transitions

extension UIViewController {
  public func present(module: UIModule,
                      animated: Bool = true,
                      leftButtonMode: UIViewControllerLeftButtonMode = .back,
                      uiConfig: ShiftUIConfig,
                      completion: @escaping Result<UIViewController, NSError>.Callback) {
    module.initialize { [weak self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let initialViewController):
        let newNavigationController = UINavigationController(rootViewController: initialViewController)
        module.navigationController = newNavigationController
        initialViewController.configureLeftNavButton(mode: leftButtonMode, uiConfig: uiConfig)
        self?.present(newNavigationController, animated: animated) {
          completion(.success(initialViewController))
        }
      }
    }
  }

  public func configureLeftNavButton(mode: UIViewControllerLeftButtonMode?, uiConfig: ShiftUIConfig?) {
    guard !navigationItem.hidesBackButton else {
      hideNavPreviousButton()
      hideNavCancelButton()
      return
    }
    if let mode = mode, let uiConfig = uiConfig {
      switch mode {
      case .back:
        showNavPreviousButton(uiConfig.iconTertiaryColor)
      case .close:
        showNavCancelButton(uiConfig.iconTertiaryColor)
      case .none:
        hideNavPreviousButton()
      }
    }
  }
}