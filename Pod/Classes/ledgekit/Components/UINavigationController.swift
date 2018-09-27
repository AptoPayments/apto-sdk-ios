//
//  UINavigationController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 29/03/2017.
//
//

import Foundation

extension UINavigationController {
  open override var childViewControllerForStatusBarStyle: UIViewController? {
    return topViewController
  }

  public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }

  public func popViewController(_ animated: Bool, completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    self.popViewController(animated: animated)
    CATransaction.commit()
  }

  func push(viewControllers: [UIViewController], animated: Bool, completion: (() -> Void)?) {
    guard !viewControllers.isEmpty else {
      completion?()
      return
    }
    if animated {
      var nonAnimatedViewControllerList = viewControllers
      let lastViewController = nonAnimatedViewControllerList.removeLast()
      self.viewControllers += nonAnimatedViewControllerList
      pushViewController(lastViewController, animated: animated, completion: completion)
    }
    else {
      self.viewControllers += viewControllers
      completion?()
    }
  }

  func pop(viewControllers: [UIViewController], animated: Bool, completion: (() -> Void)?) {
    guard let viewController = viewControllers.first else {
      completion?()
      return
    }
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    popToViewController(viewController, animated: animated)
    CATransaction.commit()
  }
}
