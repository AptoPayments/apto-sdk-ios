//
//  P2PTransferFeature.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 15/7/21.
//

import Foundation

public struct P2PTransferFeature: Codable {
    public let status: FeatureStatus?
}

public struct P2PInvite {
    public let countryCode: String?
    public let phoneNumber: String?
    public let email: String?
}

public struct P2PTransferRequest {
    public let sourceId: String
    public let recipientId: String
    public let amount: Amount

    public init(sourceId: String, recipientId: String, amount: Amount) {
        self.sourceId = sourceId
        self.recipientId = recipientId
        self.amount = amount
    }
}

public struct P2PTransferResponse: Equatable {
    public let transferId: String?
    public let status: PaymentResultStatus?
    public let sourceId: String?
    public let amount: Amount?
    public let recipientFirstName: String?
    public let recipientLastName: String?
    public let createdAt: Date?
}
