//
// ManageShiftCardPresenterTest.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 23/11/2018.
//

import XCTest
@testable import ShiftSDK

class ManageShiftCardPresenterTest: XCTestCase {
  var sut: ManageShiftCardPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let config = ManageShiftCardPresenterConfig(name: "name", imageUrl: "url", showActivateCardButton: true)
  private let interactor = ManageShiftCardInteractorFake()
  private let view = ManageShiftCardViewFake()
  private let router = ManageShiftCardModuleSpy(serviceLocator: ServiceLocatorFake())
  private let dataProvider = ModelDataProvider.provider

  override func setUp() {
    super.setUp()

    sut = ManageShiftCardPresenter(config: config)
    sut.interactor = interactor
    sut.router = router
    sut.view = view
  }

  func testViewLoadedCallInteractor() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.provideFundingSourceCalled)
  }

  func testProvideFundingSourceFailsShowError() {
    // Given
    interactor.nextProvideFundingSourceResult = .failure(BackendError(code: .other))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(view.showErrorCalled)
  }

  func testProvideFundingSourceSucceedUpdateViewModel() {
    // Given
    let card = dataProvider.card
    interactor.nextProvideFundingSourceResult = .success(card)

    // When
    sut.viewLoaded()

    // Then
    let viewModel = sut.viewModel
    XCTAssertEqual(card.lastFourDigits, viewModel.lastFour.value)
    XCTAssertEqual(card.cardHolder, viewModel.cardHolder.value)
    XCTAssertEqual(card.cardNetwork, viewModel.cardNetwork.value)
  }

  func testProvideFundingSourceSucceedLoadTransactions() {
    // Given
    let card = dataProvider.card
    interactor.nextProvideFundingSourceResult = .success(card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.provideTransactionsCalled)
    XCTAssertEqual(false, interactor.lastProvideTransactionForceRefresh)
  }

  func testPreviousTappedCallRouter() {
    // When
    sut.previousTapped()

    // Then
    XCTAssertTrue(router.backFromManageShiftCardViewerCalled)
  }

  func testCloseTappedCallRouter() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeFromManageShiftCardViewerCalled)
  }

  func testNextTappedCallRouterToPresentAccountSettings() {
    // When
    sut.nextTapped()

    // Then
    XCTAssertTrue(router.accountSettingsTappedInManageShiftCardViewerCalled)
  }

  func testCardTappedCallRouter() {
    // When
    sut.cardTapped()

    // Then
    XCTAssertTrue(router.cardSettingsTappedInManageShiftCardViewerCalled)
  }

  func testCardTappedForCreatedCardDoNotCallRouter() {
    // Given
    sut.viewModel.state.next(.created)

    // When
    sut.cardTapped()

    // Then
    XCTAssertFalse(router.cardSettingsTappedInManageShiftCardViewerCalled)
  }

  func testCardTappedForInvalidFundingSourceCallRouterToShowBalance() {
    // Given
    sut.viewModel.fundingSource.next(dataProvider.invalidFundingSource)

    // When
    sut.cardTapped()

    // Then
    XCTAssertFalse(router.cardSettingsTappedInManageShiftCardViewerCalled)
    XCTAssertTrue(router.balanceTappedInManageShiftCardViewerCalled)
  }

  func testCardSettingsTappedCallRouter() {
    // When
    sut.cardSettingsTapped()

    // Then
    XCTAssertTrue(router.cardSettingsTappedInManageShiftCardViewerCalled)
  }

  func testCardSettingsTappedForCreatedCardDoNotCallRouter() {
    // Given
    sut.viewModel.state.next(.created)

    // When
    sut.cardSettingsTapped()

    // Then
    XCTAssertFalse(router.cardSettingsTappedInManageShiftCardViewerCalled)
  }

  func testBalanceTappedCallRouter() {
    // When
    sut.balanceTapped()

    // Then
    XCTAssertTrue(router.balanceTappedInManageShiftCardViewerCalled)
  }

  func testTransactionSelectedCallRouterToShowDetails() {
    // Given
    givenInitialDataLoaded()
    interactor.nextProvideTransactionsResult = .success([dataProvider.transaction])
    sut.moreTransactionsTapped { _ in }
    let indexPath = IndexPath(row: 0, section: 0)

    // When
    sut.transactionSelected(indexPath: indexPath)

    // Then
    XCTAssertTrue(router.showTransactionDetailsCalled)
  }

  func testActivateCardTappedCallInteractor() {
    // When
    sut.activateCardTapped()

    // Then
    XCTAssertTrue(interactor.activateCardCalled)
    XCTAssertTrue(view.showLoadingSpinnerCalled)
  }

  func testCardActivationFailsShowError() {
    // Given
    interactor.nextActivateCardResult = .failure(BackendError(code: .other))

    // When
    sut.activateCardTapped()

    // Then
    XCTAssertTrue(view.showErrorCalled)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testCardActivationSucceedUpdateViewModel() {
    // Given
    interactor.nextActivateCardResult = .success(dataProvider.card)

    // When
    sut.activateCardTapped()

    // Then
    XCTAssertEqual(FinancialAccountState.active, sut.viewModel.state.value)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testRefreshCardCallInteractor() {
    // When
    sut.refreshCard()

    // Then
    XCTAssertTrue(interactor.reloadCardCalled)
    XCTAssertTrue(view.showLoadingSpinnerCalled)
  }

  func testRefreshCardReloadCardFailsShowError() {
    // Given
    interactor.nextReloadCardResult = .failure(BackendError(code: .other))

    // When
    sut.refreshCard()

    // Then
    XCTAssertTrue(view.showErrorCalled)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testReloadCardSucceedUpdateViewModel() {
    // Given
    let card = dataProvider.cardWithoutDetails
    interactor.nextReloadCardResult = .success(card)

    // When
    sut.refreshCard()

    // Then
    let viewModel = sut.viewModel
    XCTAssertEqual(card.lastFourDigits, viewModel.lastFour.value)
    XCTAssertEqual(card.cardHolder, viewModel.cardHolder.value)
    XCTAssertEqual(card.cardNetwork, viewModel.cardNetwork.value)
    XCTAssertNil(viewModel.cvv.value)
    XCTAssertNil(viewModel.pan.value)
    XCTAssertNil(viewModel.expirationMonth.value)
    XCTAssertNil(viewModel.expirationYear.value)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testShowCardInfoCallInteractor() {
    // When
    sut.showCardInfo()

    // Then
    XCTAssertTrue(interactor.loadCardInfoCalled)
    XCTAssertTrue(view.showLoadingSpinnerCalled)
  }

  func testLoadCardInfoFailsShowError() {
    // Given
    interactor.nextLoadCardInfoResult = .failure(BackendError(code: .other))

    // When
    sut.showCardInfo()

    // Then
    XCTAssertTrue(view.showErrorCalled)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testLoadCardInfoSucceedUpdateViewModelCardDetails() {
    // Given
    let cardDetails = dataProvider.cardDetails
    interactor.nextLoadCardInfoResult = .success(cardDetails)

    // When
    sut.showCardInfo()

    // Then
    let viewModel = sut.viewModel
    XCTAssertEqual(cardDetails.cvv, viewModel.cvv.value)
    XCTAssertEqual(cardDetails.pan, viewModel.pan.value)
    XCTAssertEqual(3, viewModel.expirationMonth.value)
    XCTAssertEqual(99, viewModel.expirationYear.value)
    XCTAssertEqual(true, viewModel.cardInfoVisible.value)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testHideCardInfoUpdateViewModel() {
    // When
    sut.hideCardInfo()

    // Then
    XCTAssertEqual(false, sut.viewModel.cardInfoVisible.value)
  }

  func testReloadTappedShowingSpinnerShowSpinner() {
    // Given
    givenInitialDataLoaded()

    // When
    sut.reloadTapped(showSpinner: true)

    // Then
    XCTAssertTrue(view.showLoadingSpinnerCalled)
  }

  func testInitialDataLoadedRefreshDataFromServer() {
    // When
    givenInitialDataLoaded()

    // Then
    XCTAssertTrue(interactor.reloadCardCalled)
    XCTAssertTrue(interactor.provideTransactionsCalled)
    XCTAssertNil(interactor.lastTransactionId)
    XCTAssertEqual(true, interactor.lastProvideTransactionForceRefresh)
    XCTAssertTrue(interactor.loadFundingSourcesCalled)
  }

  func testWillEnterForegroundNotificationReceivedRefreshDataFromServer() {
    // When
    NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    // Then
    XCTAssertTrue(interactor.reloadCardCalled)
    XCTAssertTrue(interactor.provideTransactionsCalled)
    XCTAssertNil(interactor.lastTransactionId)
    XCTAssertEqual(true, interactor.lastProvideTransactionForceRefresh)
    XCTAssertTrue(interactor.loadFundingSourcesCalled)
  }

  func testReloadTappedNotShowingSpinnerDoNotShowSpinner() {
    // When
    sut.reloadTapped(showSpinner: false)

    // Then
    XCTAssertFalse(view.showLoadingSpinnerCalled)
  }

  func testReloadTappedCallInteractor() {
    // Given
    givenInitialDataLoaded()

    // When
    sut.reloadTapped(showSpinner: true)

    // Then
    XCTAssertTrue(interactor.reloadCardCalled)
  }

  func testReloadTappedReloadCardFailsShowError() {
    // Given
    interactor.nextReloadCardResult = .failure(BackendError(code: .other))

    // When
    sut.reloadTapped(showSpinner: true)

    // Then
    XCTAssertTrue(view.showErrorCalled)
  }

  func testReloadCardFinishRefreshTransactions() {
    // Given
    interactor.nextReloadCardResult = .success(dataProvider.card)

    // When
    sut.reloadTapped(showSpinner: true)

    // Then
    XCTAssertTrue(interactor.provideTransactionsCalled)
    XCTAssertEqual(20, interactor.lastNumberOfRows)
    XCTAssertNil(interactor.lastTransactionId)
  }

  func testReloadTappedShowingSpinnerReloadCardFinishHideSpinner() {
    // Given
    interactor.nextReloadCardResult = .success(dataProvider.card)
    interactor.nextProvideTransactionsResult = .success([dataProvider.transaction])

    // When
    sut.reloadTapped(showSpinner: true)

    // Then
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testReloadTappedNotShowingSpinnerReloadCardFinishDoNotHideSpinner() {
    // Given
    interactor.nextReloadCardResult = .success(dataProvider.card)
    interactor.nextProvideTransactionsResult = .success([dataProvider.transaction])

    // When
    sut.reloadTapped(showSpinner: false)

    // Then
    XCTAssertFalse(view.hideLoadingSpinnerCalled)
  }

  func testInitialLoadFinishMoreTransactionsTappedCallInteractor() {
    // Given
    givenInitialDataLoaded()

    // When
    sut.moreTransactionsTapped { _ in }

    // Then
    XCTAssertTrue(interactor.provideTransactionsCalled)
  }

  func testTransactionProvidedMoreTransactionsTappedCallInteractorWithTransactionId() {
    //Given
    givenInitialDataLoaded()
    let transaction = dataProvider.transaction
    interactor.nextProvideTransactionsResult = .success([transaction])
    sut.moreTransactionsTapped { _ in }

    // When
    sut.moreTransactionsTapped { _ in }

    // Then
    XCTAssertTrue(interactor.provideTransactionsCalled)
    XCTAssertEqual(transaction.transactionId, interactor.lastTransactionId)
  }

  func testActivatePhysicalCardTappedRequestActivationCode() {
    // When
    sut.activatePhysicalCardTapped()

    // Then
    XCTAssertTrue(view.requestPhysicalActivationCodeCalled)
  }

  func testActivationCodeProvidedPhysicalCardActivationFailsShowError() {
    // Given
    interactor.nextActivatePhysicalCardResult = .failure(BackendError(code: .other))
    view.nextPhysicalCardActivationCode = "111111"

    // When
    sut.activatePhysicalCardTapped()

    // Then
    XCTAssertTrue(view.showErrorCalled)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testActivationCodeProvidedPhysicalCardActivationSucceedCallNotifyRouter() {
    // Given
    interactor.nextActivatePhysicalCardResult = .success(Void())
    view.nextPhysicalCardActivationCode = "111111"

    // When
    sut.activatePhysicalCardTapped()

    // Then
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
    XCTAssertTrue(router.physicalActivationSucceedCalled)
  }

  private func givenInitialDataLoaded() {
    let card = dataProvider.card
    interactor.nextReloadCardResult = .success(card)
    interactor.nextProvideFundingSourceResult = .success(card)
    interactor.nextProvideTransactionsResult = .success([dataProvider.transaction])
    sut.viewLoaded()
  }
}
