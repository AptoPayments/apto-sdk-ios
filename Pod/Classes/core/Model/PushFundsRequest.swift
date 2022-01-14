import Foundation

public struct PushFundsRequest {
    public let paymentSourceId: String
    public let balanceId: String
    public let amount: Amount

    public init(paymentSourceId: String, balanceId: String, amount: Amount) {
        self.paymentSourceId = paymentSourceId
        self.balanceId = balanceId
        self.amount = amount
    }
}
