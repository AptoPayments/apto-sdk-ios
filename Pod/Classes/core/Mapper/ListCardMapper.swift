//
//  CardMapper.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 20/9/21.
//

import Foundation
import SwiftyJSON

public struct ListWithPagination<T> {
    public let list: [T]
    public let page: Int?
    public let rows: Int?
    public let hasMore: Bool?
    public let totalCount: Int?
}

enum ListCardMapper {
    static func map(_ json: JSON) throws -> ListWithPagination<Card> {
        guard let list = json.linkObject as? [Card] else {
            throw MappingError.jsonError
        }
        return ListWithPagination(list: list,
                                  page: json["page"].int,
                                  rows: json["rows"].int,
                                  hasMore: json["has_more"].bool,
                                  totalCount: json["total_count"].int)
    }
}
