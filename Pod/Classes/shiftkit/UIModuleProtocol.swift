//
//  UIModuleProtocol.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

public protocol UIModuleProtocol: class {
  /// UI Configuration
  var uiConfig: ShiftUIConfig? { get set }

  /// Session
  var shiftSession: ShiftSession { get }

  /// Callbacks
  var onClose:((_ module: UIModuleProtocol) -> Void)? { get set }
  var onBack:((_ module: UIModuleProtocol) -> Void)? { get set }
  var onNext:((_ module: UIModuleProtocol) -> Void)? { get set }
  var onFinish: ((_ module: UIModuleProtocol) -> Void)? { get set }

  /// Module lifecycle
  func initialize(completion: @escaping Result<UIViewController, NSError>.Callback)
  func close()
  func back()
  func next()

  /// Add or remove content
  func push(viewController: UIViewController,
            animated: Bool?,
            leftButtonMode: UIViewControllerLeftButtonMode?,
            completion: @escaping (() -> Void))
  func popViewController(animated: Bool?,
                         completion: @escaping (() -> Void))
  func present(viewController: UIViewController,
               animated: Bool?,
               completion: @escaping (() -> Void))
  func push(module: UIModuleProtocol,
            animated: Bool?,
            leftButtonMode : UIViewControllerLeftButtonMode?,
            completion: @escaping Result<UIViewController, NSError>.Callback)
  func popModule(animated: Bool?,
                 completion: @escaping (() -> Void))
  func remove(module: UIModuleProtocol,
              completion: @escaping (() -> Void))
  func present(module: UIModuleProtocol,
               animated: Bool?,
               leftButtonMode: UIViewControllerLeftButtonMode?,
               completion: @escaping Result<UIViewController, NSError>.Callback)
  func dismissViewController(animated: Bool?,
                             completion: @escaping (() -> Void))
  func dismissModule(animated: Bool?,
                     completion: @escaping (() -> Void))
  func addChild(module: UIModuleProtocol,
                leftButtonMode: UIViewControllerLeftButtonMode?,
                completion: @escaping Result<UIViewController, NSError>.Callback)
  func addChild(viewController: UIViewController,
                leftButtonMode: UIViewControllerLeftButtonMode?,
                completion: @escaping Result<UIViewController, NSError>.Callback)

  /// Helper methods
  func showLoadingSpinner(position: SubviewPosition)
  func hideLoadingSpinner()
  func show(error: Error)
}

// Default values are not allowed in protocol definitions
public extension UIModuleProtocol {
  func push(viewController: UIViewController,
            animated: Bool? = true,
            leftButtonMode : UIViewControllerLeftButtonMode? = .back,
            completion: @escaping (() -> Void)) {
    push(viewController: viewController, animated: animated, leftButtonMode: leftButtonMode, completion: completion)
  }

  func popViewController(animated: Bool? = true, completion: @escaping (() -> Void)) {
    popViewController(animated: animated, completion: completion)
  }

  func present(viewController: UIViewController, animated: Bool? = true, completion: @escaping (() -> Void)) {
    present(viewController: viewController, animated: animated, completion: completion)
  }

  func push(module: UIModuleProtocol,
            animated: Bool? = true,
            leftButtonMode: UIViewControllerLeftButtonMode? = .back,
            completion: @escaping Result<UIViewController, NSError>.Callback) {
    push(module: module, animated: animated, leftButtonMode: leftButtonMode, completion: completion)
  }

  func popModule(animated: Bool? = true, completion: @escaping (() -> Void)) {
    popModule(animated: animated, completion: completion)
  }

  func present(module: UIModuleProtocol,
               animated: Bool? = true,
               leftButtonMode: UIViewControllerLeftButtonMode? = .close,
               completion: @escaping Result<UIViewController, NSError>.Callback) {
    present(module: module, animated: animated, leftButtonMode: leftButtonMode, completion: completion)
  }

  func dismissViewController(animated: Bool? = true, completion: @escaping (() -> Void)) {
    dismissViewController(animated: animated, completion: completion)
  }

  func dismissModule(animated: Bool? = true, completion: @escaping (() -> Void)) {
    dismissModule(animated: animated, completion: completion)
  }

  func showLoadingSpinner(position: SubviewPosition = .center) {
    showLoadingSpinner(position: position)
  }
}
