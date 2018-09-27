//
//  UISwitch.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 10/03/2018.
//

import UIKit

private var uiSwitchOnChangeListenerAssociationKey: UInt8 = 126

// onChange listener as blocks (not selectors)

extension UISwitch {
  
  // In order to create computed properties for extensions, we need a key to
  // store and access the stored property
  fileprivate struct AssociatedObjectKeys {
    static var onChangeListener = "UISwitch_onChangeListener"
  }
  
  // Set our computed property type to a closure
  var onChange: ((UISwitch) -> Void)? {
    set {
      if let newValue = newValue {
        // Computed properties get stored as associated objects
        objc_setAssociatedObject(self, &AssociatedObjectKeys.onChangeListener, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
      }
    }
    get {
      let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.onChangeListener) as? ((UISwitch) -> Void)
      return tapGestureRecognizerActionInstance
    }
  }
  
  // This is the meat of the sauce, here we create the tap gesture recognizer and
  // store the closure the user passed to us in the associated object we declared above
  public func setOnChnageListener(action: ((UISwitch) -> Void)?) {
    self.onChange = action
    self.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
  }
  
  // Every time the user taps on the UIImageView, this function gets called,
  // which triggers the closure we stored
  @objc fileprivate func switchChanged(mySwitch: UISwitch) {
    if let action = self.onChange {
      action(mySwitch)
    }
  }
  
}
