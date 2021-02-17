//
//  BankAccountDisclaimer.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 6/2/21.
//

import Foundation

public struct BankAccountDisclaimer: Equatable, Codable {
    public let agreementKeys: [String]?
    public let content: Content?
}
