//
//  NSMutableAttributedString.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/06/16.
//
//

import Foundation

extension NSMutableAttributedString {
  static func createFrom(string: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
    let retVal = NSMutableAttributedString(string: string, attributes: [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.foregroundColor: color
    ])
    return retVal
  }

  public func replacePlainTextStyle(font: UIFont, color: UIColor, lineSpacing: CGFloat = 0,
                                    paragraphSpacing: CGFloat = 12) {
    let range = NSRange(location: 0, length: self.length)
    self.enumerateAttribute(NSAttributedString.Key.font,
                            in: range,
                            options: .longestEffectiveRangeNotRequired) { (attribute, range, stop) in
      guard attribute is UIFont else {
        return
      }
      self.removeAttribute(NSAttributedString.Key.font, range: range)
      self.addAttribute(NSAttributedString.Key.font, value: font, range: range)
      self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
      let mutableParagraphStyle = NSMutableParagraphStyle()
      mutableParagraphStyle.lineSpacing = lineSpacing
      mutableParagraphStyle.paragraphSpacing = paragraphSpacing
      self.addAttributes([.paragraphStyle: mutableParagraphStyle], range: range)
    }
  }

  public func replaceLinkStyle(font: UIFont, color: UIColor, lineSpacing: CGFloat = 0, paragraphSpacing: CGFloat = 12) {
    let range = NSRange(location: 0, length: self.length)
    self.enumerateAttribute(NSAttributedString.Key.link,
                            in: range,
                            options: .longestEffectiveRangeNotRequired) { (attribute, range, stop) in
      guard let _ = attribute as? URL else {
        return
      }
      self.removeAttribute(NSAttributedString.Key.font, range: range)
      self.removeAttribute(NSAttributedString.Key.foregroundColor, range: range)
      self.addAttribute(NSAttributedString.Key.font, value: font, range: range)
      self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
      let mutableParagraphStyle = NSMutableParagraphStyle()
      mutableParagraphStyle.lineSpacing = lineSpacing
      mutableParagraphStyle.paragraphSpacing = paragraphSpacing
      self.addAttributes([.paragraphStyle: mutableParagraphStyle], range: range)
    }
  }
}
