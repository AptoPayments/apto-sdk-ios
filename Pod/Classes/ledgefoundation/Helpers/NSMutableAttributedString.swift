//
//  NSMutableAttributedString.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 13/06/16.
//
//

import Foundation

extension NSMutableAttributedString {
  static func createFrom(string: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
    let retVal = NSMutableAttributedString(string: string, attributes: [
      NSAttributedStringKey.font: font,
      NSAttributedStringKey.foregroundColor: color
    ])
    return retVal
  }

  func replacePlainTextStyle(font: UIFont, color: UIColor, lineSpacing: CGFloat = 0, paragraphSpacing: CGFloat = 12) {
    let range = NSRange(location: 0, length: self.length)
    self.enumerateAttribute(NSAttributedStringKey.font,
                            in: range,
                            options: .longestEffectiveRangeNotRequired) { (attribute, range, stop) in
      guard attribute is UIFont else {
        return
      }
      self.removeAttribute(NSAttributedStringKey.font, range: range)
      self.addAttribute(NSAttributedStringKey.font, value: font, range: range)
      self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
      let mutableParagraphStyle = NSMutableParagraphStyle()
      mutableParagraphStyle.lineSpacing = lineSpacing
      mutableParagraphStyle.paragraphSpacing = paragraphSpacing
      self.addAttributes([.paragraphStyle: mutableParagraphStyle], range: range)
    }
  }

  func replaceLinkStyle(font: UIFont, color: UIColor, lineSpacing: CGFloat = 0, paragraphSpacing: CGFloat = 12) {
    let range = NSRange(location: 0, length: self.length)
    self.enumerateAttribute(NSAttributedStringKey.link,
                            in: range,
                            options: .longestEffectiveRangeNotRequired) { (attribute, range, stop) in
      guard let _ = attribute as? URL else {
        return
      }
      self.removeAttribute(NSAttributedStringKey.font, range: range)
      self.removeAttribute(NSAttributedStringKey.foregroundColor, range: range)
      self.addAttribute(NSAttributedStringKey.font, value: font, range: range)
      self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
      let mutableParagraphStyle = NSMutableParagraphStyle()
      mutableParagraphStyle.lineSpacing = lineSpacing
      mutableParagraphStyle.paragraphSpacing = paragraphSpacing
      self.addAttributes([.paragraphStyle: mutableParagraphStyle], range: range)
    }
  }
}
