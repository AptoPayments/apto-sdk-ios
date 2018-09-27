//
//  NavigatioMenu.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 16/02/16.
//
//

import UIKit

protocol NavigationMenuListener {
  func shouldShowRefreshOffersButton() -> Bool
  func refreshOffersTapped()
}

open class NavigationMenu: NSObject {
  
  let viewController: UIViewController
  let menuListener: NavigationMenuListener
  let uiConfiguration: ShiftUIConfig
  
  init(viewController: UIViewController, uiConfiguration: ShiftUIConfig, menuListener: NavigationMenuListener) {
    self.viewController = viewController
    self.uiConfiguration = uiConfiguration
    self.menuListener = menuListener
  }
  
  func install() {
    viewController.installNavRightButton(UIImage.imageFromPodBundle("top_menu_default.png"), tintColor: self.uiConfiguration.tintColor, target: self, action: #selector(NavigationMenu.menuTapped))
  }
  
  @objc open func menuTapped() {
    var actions: [String] = []
    if menuListener.shouldShowRefreshOffersButton() {
      actions.append("navigation-menu.button.refresh-offers".podLocalized())
    }
    UIAlertController.showMenuInActionSheet(cancelButton:"general.button.cancel".podLocalized(), actions: actions) { [weak self] alertAction in
      guard let title = alertAction.title else {
        return
      }
      switch title {
      case "navigation-menu.button.refresh-offers".podLocalized():
        self?.menuListener.refreshOffersTapped()
        break
      default:
        break
      }
    }
  }
  
}
