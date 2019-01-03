//
//  ContentRenderer.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/05/2017.
//
//

import Foundation
import Down

extension Content {
  func plainTextDescription() -> String {
    switch (self) {
    case .plainText(let plainText):
      return plainText
    case .markdown(let markDown):
      return markDown
    case .externalURL(let url):
      return url.absoluteString
    }
  }

  func attributedString(font: UIFont,
                        color: UIColor,
                        linkColor: UIColor,
                        lineSpacing: CGFloat = 4) -> NSAttributedString? {
    switch self {
    case .plainText(let value):
      return value.formattedHtmlString(font: font, color: color, linkColor: linkColor, lineSpacing: lineSpacing)
    case .markdown(let value):
      let down = Down(markdownString: value)
      if let retVal = try? down.toAttributedString().mutableCopy() as? NSMutableAttributedString {
        retVal?.replacePlainTextStyle(font: font, color: color, lineSpacing: lineSpacing)
        retVal?.replaceLinkStyle(font: font, color: linkColor, lineSpacing: lineSpacing)
        return retVal
      }
      return nil
    case .externalURL(let value):
      return "<a href='\(value)'>\(value)</a>".formattedHtmlString(font: font, color: color, linkColor: linkColor)
    }
  }

  func htmlString(font: UIFont, color: UIColor, linkColor: UIColor) -> String? {
    switch self {
    case .plainText(let value):
      return value
    case .markdown(let value):
      let down = Down(markdownString: value)
      if let retVal = try? down.toHTML().mutableCopy() as? String {
        //retVal?.replacePlainTextStyle(font: font, color: color)
        //retVal?.replaceLinkStyle(font: font, color: linkColor)
        return retVal
      }
      return nil
    case .externalURL(let value):
      if let retVal = "<a href='\(value)'>\(value)</a>".formattedHtmlString(font: font, color: color, linkColor: linkColor) {
        return retVal.string
      }
      return nil
    }
  }
}
