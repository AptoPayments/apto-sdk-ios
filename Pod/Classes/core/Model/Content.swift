//
//  Content.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/04/2017.
//
//

public struct NativeContent: Equatable {
  public let asset: String?
  public let backgroundImage: String?
  public let backgroundColor: String?
  public let darkBackgroundColor: String?
}

public extension NativeContent {
  var dynamicBackgroundColor: UIColor? {
    guard let color = UIColor.colorFromHexString(backgroundColor),
      let darkColor = UIColor.colorFromHexString(darkBackgroundColor) else {
        return nil
    }
    return UIColor.dynamicColor(light: color, dark: darkColor)
  }
}

public enum Content: Equatable {
  case plainText(String)
  case markdown(String)
  case externalURL(URL)
  case nativeContent(NativeContent)

  mutating func replaceInURL(string: String, with: String?) {
    switch self {
    case .externalURL(let url):
      if let with = with {
        guard let newURL = URL(string: url.absoluteString.replace([string: with])) else {
          return
        }
        self = .externalURL(newURL)
      }
      else {
        guard let newURL = URL(string: url.absoluteString.replace([string: ""])) else {
          return
        }
        self = .externalURL(newURL)
      }
    default:
      return
    }
  }

  var isPlainText: Bool {
    if case .plainText = self {
      return true
    }
    return false
  }
}
