//
//  UIFormattedLabel.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 30/11/2016.
//
//

import Foundation

class UIFormattedLabel: UILabel {
  
  var formattingPattern = "***-**-****"
  var replacementChar: Character = "*"
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var text: String? {
    didSet {
      guard let text = self.text else {
        return
      }
      let formattedText = self.formatText(text)
      if formattedText != text {
        self.text = formattedText
      }
    }
  }
  
  func formatText(_ text:String) -> String {
    if text.count > 0 && formattingPattern.count > 0 {
      var finalText = ""
      var stop = false
      var formatterIndex = formattingPattern.startIndex
      var tempIndex = text.startIndex
      while !stop {
        let nextFormattingIndex = formattingPattern.index(after:formatterIndex)
        let nextTempIndex = text.index(after:tempIndex)
        let formattingPatternRange = (formatterIndex ..< nextFormattingIndex)
        let textRange = (tempIndex ..< nextTempIndex)
        if formattingPattern[formattingPatternRange] != String(replacementChar) {
          finalText = finalText + formattingPattern[formattingPatternRange]
          formatterIndex = formattingPattern.index(after:formatterIndex)
          if formattingPattern[formattingPatternRange] == text[textRange] {
            tempIndex = text.index(after:tempIndex)
          }
        }
        else {
          finalText = finalText + text[textRange]
          formatterIndex = formattingPattern.index(after:formatterIndex)
          tempIndex = text.index(after:tempIndex)
        }
        if formatterIndex >= formattingPattern.endIndex || tempIndex >= text.endIndex {
          stop = true
        }
      }
      return finalText
    }
    return ""
  }
  
}
