//
//  ShiftViewController.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 14/09/2018.
//
//

import UIKit
import SnapKit

class ShiftViewController: UIViewController {
  let uiConfiguration: ShiftUIConfig

  init(uiConfiguration: ShiftUIConfig) {
    self.uiConfiguration = uiConfiguration
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    switch uiConfiguration.uiStatusBarStyle {
    case .light:
      return .lightContent
    case .dark:
      return .default
    case .auto:
      if let navigationBarColor = navigationController?.navigationBar.barTintColor,
         navigationController?.isNavigationBarHidden == false {
        return navigationBarColor.isLight ? .default : .lightContent
      }
      if let backgroundColor = view.backgroundColor {
        return backgroundColor.isLight ? .default : .lightContent
      }
      return .default
    }
  }

  var topConstraint: ConstraintItem {
    if #available(iOS 11, *) {
      return view.safeAreaLayoutGuide.snp.top
    }
    return view.snp.top
  }

  var bottomConstraint: ConstraintItem {
    if #available(iOS 11, *) {
      return view.safeAreaLayoutGuide.snp.bottom
    }
    return view.snp.bottom
  }

  func showLoadingSpinner() {
    showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor, position: .center)
  }
}
