//
//  UILabel.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 08/06/16.
//
//

import Foundation

extension UILabel {
  override open func layoutSubviews() {
    super.layoutSubviews()
    self.preferredMaxLayoutWidth = self.bounds.size.width
  }
}
