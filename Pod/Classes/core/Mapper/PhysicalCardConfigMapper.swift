//
//  PhysicalCardConfigMapper.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 16/3/21.
//

import Foundation
import SwiftyJSON

struct PhysicalCardConfigMapper {
    enum MappingError: Error {
        case jsonError
    }
    static func map(_ json: JSON) throws -> PhysicalCardConfig {
        guard let issuanceFee = json["issuance_fee"].amount,
              let userAddress = json["user_address"].address else {
            throw MappingError.jsonError
        }
        return PhysicalCardConfig(issuanceFee: issuanceFee, userAddress: userAddress)
    }
}
