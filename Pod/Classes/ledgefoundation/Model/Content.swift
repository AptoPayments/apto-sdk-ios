//
//  Content.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/04/2017.
//
//

public enum Content: Equatable {
  case plainText(String)
  case markdown(String)
  case externalURL(URL)
  mutating func replaceInURL(string:String, with:String?) {
    switch self {
    case .externalURL(let url):
      if let with = with {
        guard let newURL = URL(string: url.absoluteString.replace([string : with])) else {
          return
        }
        self = .externalURL(newURL)
      }
      else {
        guard let newURL = URL(string: url.absoluteString.replace([string : ""])) else {
          return
        }
        self = .externalURL(newURL)
      }
    default:
      return
    }
  }
  var isPlainText : Bool {
    if case .plainText = self {
      return true
    }
    return false
  }
}

