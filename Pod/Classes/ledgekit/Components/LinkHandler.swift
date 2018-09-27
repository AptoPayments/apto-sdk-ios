//
//  LinkHandler.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 25/08/16.
//
//

import UIKit
import TTTAttributedLabel

public protocol URLHandlerProtocol {
  func showExternal(url:URL, headers:[String:String]?, useSafari: Bool?)
}

open class LinkHandler: NSObject, TTTAttributedLabelDelegate {
  
  let urlHandler: URLHandlerProtocol
  
  public init(urlHandler: URLHandlerProtocol) {
    self.urlHandler = urlHandler
  }
  
  open func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    urlHandler.showExternal(url:url, headers:nil, useSafari:false)
  }
  
}
