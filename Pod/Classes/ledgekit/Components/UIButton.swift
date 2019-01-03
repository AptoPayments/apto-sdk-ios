//
//  UIButton.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 13/02/16.
//
//

import UIKit
import Bond

extension UIButton {
  static func roundedButtonWith(_ title: String,
                                backgroundColor: UIColor,
                                accessibilityLabel: String? = nil,
                                tapHandler: @escaping () -> Void) -> UIButton {
    let button = UIButton()
    button.layer.masksToBounds = true
    button.layer.cornerRadius = 5
    button.clipsToBounds = true
    button.backgroundColor = backgroundColor
    button.setTitle(title, for: UIControlState())
    button.contentEdgeInsets = UIEdgeInsetsMake(5, 15, 5, 15)
    button.accessibilityLabel = accessibilityLabel
    let _ = button.reactive.tap.observeNext(with: tapHandler)
    return button
  }

  static func circledButtonWith(_ icon: UIImage?,
                                backgroundColor: UIColor?,
                                borderColor: UIColor?,
                                borderWidth: CGFloat,
                                diameter: CGFloat,
                                imageInset: CGFloat,
                                accessibilityLabel: String? = nil,
                                tapHandler: @escaping () -> Void) -> UIButton {
    let button = UIButton()
    button.layer.masksToBounds = true
    button.layer.cornerRadius = diameter / 2
    button.layer.borderColor = borderColor?.cgColor
    button.layer.borderWidth = borderWidth
    button.clipsToBounds = true
    button.backgroundColor = backgroundColor
    button.setImage(icon, for: UIControlState())
    button.imageEdgeInsets = UIEdgeInsetsMake(imageInset, imageInset, imageInset, imageInset)
    button.accessibilityLabel = accessibilityLabel
    let _ = button.reactive.tap.observeNext(with: tapHandler)
    return button
  }

  func updateAttributedTitle(_ title: String?, for state: UIControl.State) {
    guard let attributedTitle = self.attributedTitle(for: state), let newTitle = title else {
      self.setTitle(title, for: state)
      return
    }
    let mutableAttributedString = NSMutableAttributedString(attributedString: attributedTitle)
    mutableAttributedString.mutableString.setString(newTitle)
    self.setAttributedTitle(mutableAttributedString, for: state)
  }
}

extension UIButton {
  //    This method sets an image and title for a UIButton and
  //    repositions the titlePosition with respect to the button image.
  //    Add additionalSpacing between the button image & title as required
  //    For titlePosition, the function only respects UIViewContentModeTop, UIViewContentModeBottom,
  //    UIViewContentModeLeft and UIViewContentModeRight
  //    All other titlePositions are ignored
  @objc func set(image anImage: UIImage,
                 title: String,
                 titlePosition: UIViewContentMode,
                 additionalSpacing: CGFloat,
                 state: UIControlState) {
    self.imageView?.contentMode = .center
    self.setImage(anImage, for: state)
    positionLabelRespectToImage(title as NSString, position: titlePosition, spacing: additionalSpacing)
    self.titleLabel?.contentMode = .center
    self.setTitle(title, for: state)
  }

  fileprivate func positionLabelRespectToImage(_ title: NSString, position: UIViewContentMode, spacing: CGFloat) {
    let imageSize = self.imageRect(forContentRect: self.frame)
    let titleFont = self.titleLabel?.font!
    let titleSize = title.size(withAttributes: [NSAttributedStringKey.font: titleFont!])

    var titleInsets: UIEdgeInsets
    var imageInsets: UIEdgeInsets

    switch (position){
    case .top:
      titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + spacing),
                                 left: -(imageSize.width),
                                 bottom: 0,
                                 right: 0)
      imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
    case .bottom:
      titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + spacing),
                                 left: -(imageSize.width),
                                 bottom: 0,
                                 right: 0)
      imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
    case .left:
      titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
      imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -(titleSize.width * 2 + spacing))
    case .right:
      titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
      imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    default:
      titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    self.titleEdgeInsets = titleInsets
    self.imageEdgeInsets = imageInsets
  }
}
