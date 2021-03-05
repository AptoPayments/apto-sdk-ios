//
//  ACHAccountFeature.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 21/1/21.
//

import Foundation

public struct ACHAccountFeature: Codable {
    public let status: FeatureStatus?
    public let isAccountProvisioned: Bool?
    public let disclaimer: Disclaimer?
    public let achAccountDetails: ACHAccountDetails?
}
