//
//  ApplePayIAPIssuerResponse.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 19/4/21.
//

import Foundation

public struct ApplePayIAPIssuerResponse: Equatable {
    public let encryptedPassData: Data
    public let activationData: Data
    public let ephemeralPublicKey: Data
}
