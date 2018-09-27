//
//  ShiftViewController.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 14/09/2018.
//
//

import UIKit

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
    return uiConfiguration.statusBarStyle
  }
}
