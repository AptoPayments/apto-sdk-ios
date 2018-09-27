//
//  UIApplication.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 05/04/16.
//
//

import Foundation

extension UIApplication {
  
  public class func topViewController(
    _ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController)
    -> UIViewController?
  {
    if let nav = base as? UINavigationController {
      return self.topViewController(nav.visibleViewController)
    }
    
    if let tab = base as? UITabBarController {
      let moreNavigationController = tab.moreNavigationController
      
      if let top = moreNavigationController.topViewController, top.view.window != nil {
        return self.topViewController(top)
      }
      else if let selected = tab.selectedViewController {
        return self.topViewController(selected)
      }
    }
    
    if let presented = base?.presentedViewController {
      return self.topViewController(presented)
    }
    
    return base
  }
  
}
