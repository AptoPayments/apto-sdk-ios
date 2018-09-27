//
//  StatusLabelHandler.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 30/03/16.
//
//

import Foundation
import TTTAttributedLabel

class StatusLabelHandler {

  let label: TTTAttributedLabel
  let uiConfiguration: ShiftUIConfig
  var text: String? {
    didSet {
      guard let _ = text else {
        return
      }
      self.updateStatusLabel()
    }
  }
  var textColor = UIColor.black {
    didSet {
      guard let _ = text else {
        return
      }
      self.updateStatusLabel()
    }
  }

  init(label:TTTAttributedLabel, uiConfiguration:ShiftUIConfig) {
    self.label = label
    self.uiConfiguration = uiConfiguration
  }

  func updateStatusLabel() {

    guard let text = self.text else {
      label.attributedText = NSAttributedString(string:"")
      return
    }

    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector.matches(in: text, options: [], range: NSMakeRange(0, text.count))
    if matches.count == 0 {
      label.attributedText = self.statusAttributed(text:text)
    }
    else {
      let finalString = NSMutableAttributedString()
      var idx = 0
      for match in matches {
        let range = NSRange.init(location: idx, length: match.range.location - idx)
        if finalString.string != "" {
          finalString.append(NSAttributedString(string: "\n\n"))
        }
        finalString.append(self.statusAttributed(text: (text as NSString).substring(with: range)))
        if match.range.location > 0 {
          finalString.append(NSAttributedString(string: "\n\n"))
        }
        if URL(string: (text as NSString).substring(with: match.range)) != nil {
          finalString.append(self.statusAttributed(link: (text as NSString).substring(with: match.range)))
        }
        else {
          finalString.append(self.statusAttributed(text: (text as NSString).substring(with: match.range)))
        }
        idx = match.range.location + match.range.length
      }
      label.attributedText = finalString
      let plainText = finalString.string
      let matches = detector.matches(in: plainText, options: [], range: NSMakeRange(0, plainText.count))
      for match in matches {
        if let url = URL(string: (plainText as NSString).substring(with: match.range)) {
          let checkingResult = NSTextCheckingResult.linkCheckingResult(range: match.range, url: url)
          label.addLink(with: checkingResult, attributes: [
            NSAttributedStringKey.font:self.uiConfiguration.fonth4,
            NSAttributedStringKey.foregroundColor:self.uiConfiguration.tintColor
            ])
        }
      }
    }
  }

  func statusAttributed(text:String) -> NSAttributedString {
    return NSAttributedString(string: text, attributes: [
      NSAttributedStringKey.font:self.uiConfiguration.fonth4,
      NSAttributedStringKey.foregroundColor:self.textColor
      ])
  }

  func statusAttributed(link text:String) -> NSAttributedString {
    return NSAttributedString(string: text, attributes: [
      NSAttributedStringKey.font:self.uiConfiguration.fonth4,
      NSAttributedStringKey.foregroundColor:self.uiConfiguration.tintColor
      ])
  }

}
