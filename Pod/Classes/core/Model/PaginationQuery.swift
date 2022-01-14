import Foundation

public struct PaginationQuery {
    public let limit: Int?
    public let startingAfter: String?
    public let endingBefore: String?

    public init(limit: Int?, startingAfter: String? = nil, endingBefore: String? = nil) {
        self.limit = limit
        self.startingAfter = startingAfter
        self.endingBefore = endingBefore
    }

    public static var `default` = PaginationQuery(limit: 50)
}
