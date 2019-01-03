//
// ManageShiftCardInteractorTest.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 23/11/2018.
//

import XCTest
@testable import ShiftSDK

class ManageShiftCardInteractorTest: XCTestCase {
  var sut: ManageShiftCardInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  private let session = ServiceLocatorFake().sessionFake
  private let card = ModelDataProvider.provider.card
  private var shiftCardSession: ShiftCardSessionFake! // swiftlint:disable:this implicitly_unwrapped_optional
  private let dataProvider = ModelDataProvider.provider

  override func setUp() {
    super.setUp()

    sut = ManageShiftCardInteractor(shiftSession: session, card: card)
    shiftCardSession = session.setUpShiftCardSession()
  }

  func testProvideFundingSourceCallSession() {
    // When
    sut.provideFundingSource(forceRefresh: true) { _ in }

    // Then
    XCTAssertTrue(shiftCardSession.getCardFundingSourceCalled)
    XCTAssertEqual(true, shiftCardSession.lastForceRefreshToGetFundingSource)
  }

  func testProvideFundingSourceWithoutForceRefreshCallSessionWithoutForceRefresh() {
    // When
    sut.provideFundingSource(forceRefresh: false) { _ in }

    // Then
    XCTAssertEqual(false, shiftCardSession.lastForceRefreshToGetFundingSource)
  }

  func testGetFundingSourceFailsCallbackError() {
    // Given
    var returnedResult: Result<Card, NSError>?
    shiftCardSession.nextGetCardFundingSourceResult = .failure(BackendError(code: .other))

    // When
    sut.provideFundingSource(forceRefresh: true) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testGetFundingSourceSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<Card, NSError>?
    shiftCardSession.nextGetCardFundingSourceResult = .success(dataProvider.fundingSource)

    // When
    sut.provideFundingSource(forceRefresh: true) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testGetFundingSourceSucceedSetCardFundingSource() {
    // Given
    let fundingSource = dataProvider.fundingSource
    shiftCardSession.nextGetCardFundingSourceResult = .success(fundingSource)

    // When
    sut.provideFundingSource(forceRefresh: true) { _ in }

    // Then
    XCTAssertEqual(fundingSource, card.fundingSource)
  }

  func testReloadCardCallSessionRetrievingBalance() {
    // When
    sut.reloadCard { _ in }

    // Then
    XCTAssertTrue(session.getFinancialAccountCalled)
    XCTAssertEqual(true, session.lastGetFinancialAccountRetrieveBalances)
  }

  func testReloadCardGetFinancialAccountFailsCallbackError() {
    // Given
    session.nextGetFinancialAccountResult = .failure(BackendError(code: .other))
    var returnedResult: Result<Card, NSError>?

    // When
    sut.reloadCard { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testReloadCardGetFinancialAccountSucceedCallbackSuccess() {
    // Given
    session.nextGetFinancialAccountResult = .success(dataProvider.card)
    var returnedResult: Result<Card, NSError>?

    // When
    sut.reloadCard { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testLoadCardInfoCallSessionRetrievingBalance() {
    // When
    sut.loadCardInfo { _ in }

    // Then
    XCTAssertTrue(session.getCardDetailsCalled)
  }

  func testLoadCardInfoGetFinancialAccountFailsCallbackError() {
    // Given
    session.nextGetCardDetailsResult = .failure(BackendError(code: .other))
    var returnedResult: Result<CardDetails, NSError>?

    // When
    sut.loadCardInfo { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testLoadCardInfoGetFinancialAccountSucceedCallbackSuccess() {
    // Given
    session.nextGetCardDetailsResult = .success(dataProvider.cardDetails)
    var returnedResult: Result<CardDetails, NSError>?

    // When
    sut.loadCardInfo { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testActivateCardCallCardSession() {
    // When
    sut.activateCard { _ in }

    // Then
    XCTAssertTrue(shiftCardSession.activateCardCalled)
  }

  func testCardActivationFailsCallbackError() {
    // Given
    var returnedResult: Result<Card, NSError>?
    shiftCardSession.nextActivateCardResult = .failure(BackendError(code: .other))

    // When
    sut.activateCard { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testCardActivationSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<Card, NSError>?
    shiftCardSession.nextActivateCardResult = .success(dataProvider.card)

    // When
    sut.activateCard { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testProvideTransactionsCallCardSession() {
    // When
    sut.provideTransactions(rows: 20, lastTransactionId: nil, forceRefresh: true) { _ in }

    // Then
    XCTAssertTrue(shiftCardSession.cardTransactionsCalled)
  }

  func testRetrieveTransactionsFailsCallbackFailure() {
    // Given
    var returnedResult: Result<[Transaction], NSError>?
    shiftCardSession.nextCardTransactionsResult = .failure(BackendError(code: .other))

    // When
    sut.provideTransactions(rows: 20, lastTransactionId: nil, forceRefresh: true) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testRetrieveTransactionsSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<[Transaction], NSError>?
    shiftCardSession.nextCardTransactionsResult = .success([dataProvider.transaction])

    // When
    sut.provideTransactions(rows: 20, lastTransactionId: nil, forceRefresh: true) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testActivatePhysicalCardCallCardSession() {
    // When
    sut.activatePhysicalCard(code: "111111") { _ in }

    // Then
    XCTAssertTrue(shiftCardSession.activatePhysicalCardCalled)
  }

  func testPhysicalActivationCallFailsCallbackFailure() {
    // Given
    var returnedResult: Result<Void, NSError>?
    shiftCardSession.nextActivatePhysicalCardResult = .failure(BackendError(code: .other))

    // When
    sut.activatePhysicalCard(code: "111111") { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testPhysicalActivationOperationFailsCallbackFailure() {
    // Given
    var returnedResult: Result<Void, NSError>?
    let activationResult = PhysicalCardActivationResult(type: .error, errorCode: 90211, errorMessage: nil)
    shiftCardSession.nextActivatePhysicalCardResult = .success(activationResult)

    // When
    sut.activatePhysicalCard(code: "111111") { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testPhysicalActivationOperationSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<Void, NSError>?
    let activationResult = PhysicalCardActivationResult(type: .activated, errorCode: nil, errorMessage: nil)
    shiftCardSession.nextActivatePhysicalCardResult = .success(activationResult)

    // When
    sut.activatePhysicalCard(code: "111111") { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testLoadFundingSourceCallCardSession() {
    // When
    sut.loadFundingSources { _ in }

    // Then
    XCTAssertTrue(shiftCardSession.cardFundingSourcesCalled)
    XCTAssertEqual(true, shiftCardSession.lastCardFundingSourcesForceRefresh)
  }

  func testCardFundingSourcesFailsCallbackFailure() {
    // Given
    var returnedResult: Result<[FundingSource], NSError>?
    shiftCardSession.nextCardFundingSourcesResult = .failure(BackendError(code: .other))

    // When
    sut.loadFundingSources { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testCardFundingSourcesSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<[FundingSource], NSError>?
    shiftCardSession.nextCardFundingSourcesResult = .success([dataProvider.fundingSource])

    // When
    sut.loadFundingSources { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }
}
