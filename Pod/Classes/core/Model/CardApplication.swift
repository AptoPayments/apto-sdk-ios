//
//  CardApplication.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 20/06/2018.
//
//

public enum CardApplicationStatus: String {
  case unknown
  case created
  case pending = "pending_kyc"
  case approved
  case rejected
}

public struct CardApplication: WorkflowObject {
  public let id: String
  public let status: CardApplicationStatus
  public let applicationDate: Date
  public let workflowObjectId: String
  public var nextAction: WorkflowAction
}
