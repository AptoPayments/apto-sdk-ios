//
//  CardApplication.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 20/06/2018.
//
//

enum CardApplicationStatus: String {
  case unknown
  case created
  case pending = "pending_kyc"
  case approved
  case rejected
}

struct CardApplication: WorkflowObject {
  let id: String
  let status: CardApplicationStatus
  let applicationDate: Date
  let workflowObjectId: String
  let nextAction: WorkflowAction
}
