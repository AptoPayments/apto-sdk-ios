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

  private(set) var cancelCardApplicationCalled = false
  private(set) var lastCancelCardApplicationId: String?
  override func cancelCardApplication(_ applicationId: String, callback: @escaping Result<Void, NSError>.Callback) {
    cancelCardApplicationCalled = true
    lastCancelCardApplicationId = applicationId
  }

  private(set) var getCardFundingSourceCalled = false
  private(set) var lastCardToGetFundingSource: Card?
  private(set) var lastForceRefreshToGetFundingSource: Bool?
  override func getCardFundingSource(card: Card,
                                     forceRefresh: Bool = true,
                                     callback: @escaping Result<FundingSource?, NSError>.Callback) {
    getCardFundingSourceCalled = true
    lastCardToGetFundingSource = card
    lastForceRefreshToGetFundingSource = forceRefresh
  }

  private(set) var activateCardCalled = false
  private(set) var lastCardToActivate: Card?
  override func activate(card: Card, callback: @escaping Result<Card, NSError>.Callback) {
    activateCardCalled = true
    lastCardToActivate = card
  }

  private(set) var cardTransactionsCalled = false
  private(set) var lastCardToRetrieveTransactions: Card?
  private(set) var lastTransactionIdRetrieved: String?
  private(set) var lastCardTransactionsForceRefresh: Bool?
  override func cardTransactions(card: Card,
                                 page: Int?,
                                 rows: Int?,
                                 lastTransactionId: String?,
                                 forceRefresh: Bool,
                                 callback: @escaping Result<[Transaction], NSError>.Callback) {
    cardTransactionsCalled = true
    lastCardToRetrieveTransactions = card
    lastTransactionIdRetrieved = lastTransactionId
    lastCardTransactionsForceRefresh = forceRefresh
  }

  private(set) var activatePhysicalCardCalled = false
  private(set) var lastPhysicalCardToActivate: Card?
  private(set) var lastPhysicalCardActivationCode: String?
  override func activatePhysical(card: Card,
                                 code: String,
                                 callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback) {
    activatePhysicalCardCalled = true
    lastPhysicalCardToActivate = card
    lastPhysicalCardActivationCode = code
  }

  private(set) var cardFundingSourcesCalled = false
  private(set) var lastCardFundingSourcesPage: Int?
  private(set) var lastCardFundingSourcesRows: Int?
  private(set) var lastCardFundingSourcesForceRefresh: Bool?
  override func cardFundingSources(card: Card,
                                   page: Int?,
                                   rows: Int?,
                                   forceRefresh: Bool = true,
                                   callback: @escaping Result<[FundingSource], NSError>.Callback) {
    cardFundingSourcesCalled = true
    lastCardFundingSourcesPage = page
    lastCardFundingSourcesRows = rows
    lastCardFundingSourcesForceRefresh = forceRefresh
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

  var nextCancelCardApplicationResult: Result<Void, NSError>?
  override func cancelCardApplication(_ applicationId: String, callback: @escaping Result<Void, NSError>.Callback) {
    super.cancelCardApplication(applicationId, callback: callback)

    if let result = nextCancelCardApplicationResult {
      callback(result)
    }
  }

  var nextGetCardFundingSourceResult: Result<FundingSource?, NSError>?
  override func getCardFundingSource(card: Card,
                                     forceRefresh: Bool = true,
                                     callback: @escaping Result<FundingSource?, NSError>.Callback) {
    super.getCardFundingSource(card: card, forceRefresh: forceRefresh, callback: callback)

    if let result = nextGetCardFundingSourceResult {
      callback(result)
    }
  }

  var nextActivateCardResult: Result<Card, NSError>?
  override func activate(card: Card, callback: @escaping Result<Card, NSError>.Callback) {
    super.activate(card: card, callback: callback)

    if let result = nextActivateCardResult {
      callback(result)
    }
  }

  var nextCardTransactionsResult: Result<[Transaction], NSError>?
  override func cardTransactions(card: Card,
                                 page: Int?,
                                 rows: Int?,
                                 lastTransactionId: String?,
                                 forceRefresh: Bool,
                                 callback: @escaping Result<[Transaction], NSError>.Callback) {
    super.cardTransactions(card: card,
                           page: page,
                           rows: rows,
                           lastTransactionId: lastTransactionId,
                           forceRefresh: forceRefresh,
                           callback: callback)

    if let result = nextCardTransactionsResult {
      callback(result)
    }
  }

  var nextActivatePhysicalCardResult: Result<PhysicalCardActivationResult, NSError>?
  override func activatePhysical(card: Card,
                                 code: String,
                                 callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback) {
    super.activatePhysical(card: card, code: code, callback: callback)

    if let result = nextActivatePhysicalCardResult {
      callback(result)
    }
  }

  var nextCardFundingSourcesResult: Result<[FundingSource], NSError>?
  override func cardFundingSources(card: Card,
                                   page: Int?,
                                   rows: Int?,
                                   forceRefresh: Bool = true,
                                   callback: @escaping Result<[FundingSource], NSError>.Callback) {
    super.cardFundingSources(card: card, page: page, rows: rows, forceRefresh: forceRefresh, callback: callback)

    if let result = nextCardFundingSourcesResult {
      callback(result)
    }
  }
}
