//
//  BankAccountFeature.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 21/1/21.
//

import Foundation

public struct BankAccountFeature: Codable {
    public let status: FeatureStatus?
    public let isAccountProvisioned: Bool?
    public let bankAccountDetails: BankAccountDetails?
}
