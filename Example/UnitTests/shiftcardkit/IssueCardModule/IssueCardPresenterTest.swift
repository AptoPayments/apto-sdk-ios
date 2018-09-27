//
//  IssueCardPresenterTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import XCTest
@testable import ShiftSDK

class IssueCardPresenterTest: XCTestCase {
  private var sut: IssueCardPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var router = serviceLocator.moduleLocatorFake.issueCardModuleSpy
  private lazy var interactor = serviceLocator.interactorLocatorFake.issueCardInteractorFake

  override func setUp() {
    super.setUp()

    sut = IssueCardPresenter(router: router, interactor: interactor)
  }

  func testViewLoadedCallInteractorToIssueCardSetViewModelToLoadingState() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.issueCardCalled)
    XCTAssertEqual(IssueCardViewState.loading, sut.viewModel.state.value)
  }

  func testIssueCardFailureSetViewModelToErrorState() {
    // Given
    interactor.nextIssueCardResult = .failure(BackendError(code: .other))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(IssueCardViewState.error, sut.viewModel.state.value)
  }

  func testIssueCardSucceedCallCardIssued() {
    // Given
    interactor.nextIssueCardResult = .success(ModelDataProvider.provider.card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(router.cardIssuedCalled)
  }

  func testRetryTappedCallInteractorToIssueCardSetViewModelToLoadingState() {
    // When
    sut.retryTapped()

    // Then
    XCTAssertTrue(interactor.issueCardCalled)
    XCTAssertEqual(IssueCardViewState.loading, sut.viewModel.state.value)
  }
}
