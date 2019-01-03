//
//  UINavigationBar.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 01/08/2018.
//
//

extension UINavigationBar {

  func setUpWith(uiConfig: ShiftUIConfig) {
    backgroundColor = uiConfig.uiNavigationPrimaryColor
    barTintColor = uiConfig.uiNavigationPrimaryColor
    tintColor = uiConfig.textPrimaryColor
    titleTextAttributes = [
      NSAttributedStringKey.foregroundColor: uiConfig.textTopBarColor
    ]
    isTranslucent = false
  }

  func setUp(barTintColor: UIColor, tintColor: UIColor) {
    self.backgroundColor = barTintColor
    self.barTintColor = barTintColor
    self.tintColor = tintColor
    titleTextAttributes = [
      NSAttributedStringKey.foregroundColor: tintColor
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

  func setOpaque(uiConfig: ShiftUIConfig, bgColor: UIColor? = nil, tintColor: UIColor? = nil) {
    setBackgroundImage(nil, for: .default)
    isTranslucent = false
    showShadow()
    barTintColor = tintColor ?? uiConfig.uiPrimaryColor
    backgroundColor = bgColor ?? uiConfig.uiPrimaryColor
  }

}
