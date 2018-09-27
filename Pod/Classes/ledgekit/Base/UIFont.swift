//
//  UIFont.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 09/10/2017.
//
//

import UIKit

extension UIFont {
  
  func fontByReplacing(fontFace:String) -> UIFont {
    let newFontDescriptor = self.fontDescriptor.withFace(fontFace)
    return UIFont(descriptor: newFontDescriptor, size: self.pointSize)
  }
  
}
