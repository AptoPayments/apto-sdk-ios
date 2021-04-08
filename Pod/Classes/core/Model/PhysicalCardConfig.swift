//
//  PhysicalCardConfig.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 16/3/21.
//

import Foundation

/// A configuration object containing information about cost and delivery of the physical card.
public struct PhysicalCardConfig: Equatable {
    /// `issuanceFee`, if not nil, identifies the cost of printing the card and delivers to the user's address
    public let issuanceFee: Amount?
    /// `userAddress`, if not nil, identifies the pysicial card delivery's address
    public let userAddress: Address?
}
