import Foundation
import SwiftyJSON

public enum PaymentResultStatus: String {
  case processed
  case pending
  case failed
}

public struct PaymentResult {
  public let id: String?
  public let amount: Amount
  public let destinationId: String
  public let source: PaymentSource
  public let status: PaymentResultStatus
  public let createdAt: Date
}

extension JSON {
  var paymentResult: PaymentResult? {
    let paymentResult = self["payment"]
    let id = paymentResult["id"].string
    
    guard let amount = paymentResult["amount"].amount, let destinationId = paymentResult["destination_id"].string, let source = paymentResult.paymentSource(with: "source"), let statusValue = paymentResult["status"].string, let status = PaymentResultStatus(rawValue: statusValue) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                                  reason: "Can't parse PaymentResult \(self)"))
      return nil
    }
    
    guard let createdAtValue = paymentResult["created_at"].string, let createdAt = Date.timeFromISO8601(createdAtValue) else { return nil
    }
      
    return PaymentResult(
      id: id,
      amount: amount,
      destinationId: destinationId,
      source: source,
      status: status,
      createdAt: createdAt
    )
  }
}
