//
//  BankAccountDetails.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 18/1/21.
//

import Foundation

public struct BankAccountDetails: Equatable, Codable {
    public let routingNumber: String?
    public let accountNumber: String?
}
