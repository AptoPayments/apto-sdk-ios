//
//  IssueCardInteractorTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import XCTest
@testable import ShiftSDK

class IssueCardInteractorTest: XCTestCase {
  private var sut: IssueCardInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  //Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var shiftCardSession: ShiftCardSessionFake = serviceLocator.sessionFake.setUpShiftCardSession()
  private lazy var dataProvider = ModelDataProvider.provider
  private lazy var application: CardApplication = dataProvider.cardApplication

  override func setUp() {
    super.setUp()

    sut = IssueCardInteractor(shiftCardSession: shiftCardSession, application: application)
  }

  func testIssueCardCalledCallSessionToIssueCard() {
    // When
    sut.issueCard() { _ in }

    // Then
    XCTAssertTrue(shiftCardSession.issueCardCalled)
    XCTAssertEqual(shiftCardSession.lastIssueCardApplicationId, application.id)
  }

  func testIssueCardFailureCallbackError() {
    // Given
    let error = BackendError(code: .undefinedError)
    shiftCardSession.nextIssueCardResult = .failure(error)

    // When
    var result: Result<Card, NSError>?
    sut.issueCard { returnedResult in
      result = returnedResult
    }

    // Then
    XCTAssertTrue(result!.isFailure) // swiftlint:disable:this force_unwrapping
  }

  func testIssueCardSucceedCallbackSuccess() {
    // Given
    let card = dataProvider.card
    shiftCardSession.nextIssueCardResult = .success(card)

    // When
    var result: Result<Card, NSError>?
    sut.issueCard { returnedResult in
      result = returnedResult
    }

    // Then
    XCTAssertTrue(result!.isSuccess) // swiftlint:disable:this force_unwrapping
  }
}
