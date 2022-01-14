//
//  CardSerializer.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 21/10/2016.
//
//

import Foundation

public extension Card {
    override func jsonSerialize() -> [String: AnyObject] {
        var data = super.jsonSerialize()
        data["type"] = "card" as AnyObject
        if let cardNetwork = cardNetwork {
            data["card_network"] = "\(cardNetwork)" as AnyObject
        }
        data["last_four"] = lastFourDigits as AnyObject
        data["expiration"] = details?.expiration as AnyObject
        data["pan"] = panToken as AnyObject
        data["cvv"] = cvvToken as AnyObject
        return data
    }
}
