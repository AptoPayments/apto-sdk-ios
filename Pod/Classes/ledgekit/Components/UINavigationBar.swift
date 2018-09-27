//
//  UINavigationBar.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 01/08/2018.
//
//

extension UINavigationBar {

  func setUpWith(uiConfig: ShiftUIConfig) {
    backgroundColor = uiConfig.uiPrimaryColor
    barTintColor = uiConfig.uiPrimaryColor
    tintColor = uiConfig.textPrimaryColor
    titleTextAttributes = [
      NSAttributedStringKey.foregroundColor: uiConfig.textTopBarColor
    ]
    isTranslucent = false
  }

  func hideShadow() {
    shadowImage = UIImage()
  }

  func showShadow() {
    shadowImage = nil
  }

  func setTransparent() {
    setBackgroundImage(UIImage(), for: .default)
    isTranslucent = true
    hideShadow()
    barTintColor = .clear
    backgroundColor = .clear
  }

  func setOpaque(uiConfig: ShiftUIConfig) {
    setBackgroundImage(nil, for: .default)
    isTranslucent = false
    showShadow()
    barTintColor = uiConfig.uiPrimaryColor
    backgroundColor = uiConfig.uiPrimaryColor
  }

}
