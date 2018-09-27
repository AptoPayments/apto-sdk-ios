//
//  ShiftCardSessionTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 28/06/2018.
//
//

@testable import ShiftSDK

class ShiftCardSessionSpy: ShiftCardSession {
  private(set) var acceptDisclaimerCalled = false
  private(set) var lastWorkflowObjectAccepted: WorkflowObject?
  private(set) var lastWorkflowActionAccepted: WorkflowAction?
  private(set) var lastDisclaimerAcceptedCallback: Result<Void, NSError>.Callback?
  override func acceptDisclaimer(_ workflowObject: WorkflowObject,
                                 workflowAction: WorkflowAction,
                                 callback: @escaping Result<Void, NSError>.Callback) {
    acceptDisclaimerCalled = true
    lastWorkflowObjectAccepted = workflowObject
    lastWorkflowActionAccepted = workflowAction
    lastDisclaimerAcceptedCallback = callback
  }

  private(set) var issueCardCalled = false
  private(set) var lastIssueCardApplicationId: String?
  private(set) var lastIssueCardCallback: Result<Card, NSError>.Callback?
  override func issueCard(_ applicationId: String, callback: @escaping Result<Card, NSError>.Callback) {
    issueCardCalled = true
    lastIssueCardApplicationId = applicationId
    lastIssueCardCallback = callback
  }

  private(set) var setBalanceStoreCalled = false
  private(set) var lastSetBalanceStoreApplicationId: String?
  private(set) var lastSetBalanceStoreCustodian: Custodian?
  private(set) var lastSetBalanceStoreCallback: Result<SelectBalanceStoreResult, NSError>.Callback?
  override func setBalanceStore(_ applicationId: String,
                                custodian: Custodian,
                                callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {
    setBalanceStoreCalled = true
    lastSetBalanceStoreApplicationId = applicationId
    lastSetBalanceStoreCustodian = custodian
    lastSetBalanceStoreCallback = callback
  }
}

class ShiftCardSessionFake: ShiftCardSessionSpy {
  var nextAcceptDisclaimerResult: Result<Void, NSError>?
  override func acceptDisclaimer(_ workflowObject: WorkflowObject,
                                 workflowAction: WorkflowAction,
                                 callback: @escaping Result<Void, NSError>.Callback) {
    super.acceptDisclaimer(workflowObject, workflowAction: workflowAction, callback: callback)

    if let result = nextAcceptDisclaimerResult {
      callback(result)
    }
  }

  var nextIssueCardResult: Result<Card, NSError>?
  override func issueCard(_ applicationId: String, callback: @escaping Result<Card, NSError>.Callback) {
    super.issueCard(applicationId, callback: callback)

    if let result = nextIssueCardResult {
      callback(result)
    }
  }

  var nextSetBalanceStoreResult: Result<SelectBalanceStoreResult, NSError>?
  override func setBalanceStore(_ applicationId: String,
                                custodian: Custodian,
                                callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {
    super.setBalanceStore(applicationId, custodian: custodian, callback: callback)

    if let result = nextSetBalanceStoreResult {
      callback(result)
    }
  }
}
