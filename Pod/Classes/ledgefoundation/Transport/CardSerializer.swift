//
//  CardSerializer.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 21/10/2016.
//
//

import Foundation


extension Card {
  
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["type"]         = "card" as AnyObject
    if let cardNetwork = self.cardNetwork {
      data["card_network"]   = "\(cardNetwork)" as AnyObject
    }
    data["last_four"]    = self.lastFourDigits as AnyObject
    data["expiration"]   = self.expiration as AnyObject
    data["pan"]    = self.panToken as AnyObject
    data["cvv"]    = self.cvvToken as AnyObject
    return data
  }
  
}
