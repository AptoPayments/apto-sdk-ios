//
//  UITextField.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 06/06/2018.
//

import UIKit

extension UITextField {

  func positionCursor(atIndex: Int) {
    if let newPosition = position(from: beginningOfDocument, offset: atIndex) {
      selectedTextRange = textRange(from: newPosition, to: newPosition)
    }
  }

}
