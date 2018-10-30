//
//  ShowDisclaimerActionModuleTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 28/06/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import ShiftSDK

class ShowDisclaimerActionModuleTest: XCTestCase {
  private var sut: ShowDisclaimerActionModule!

  // Collaborators
  private let serviceLocator: ServiceLocatorFake = ServiceLocatorFake()
  private let disclaimer: Content = .plainText("Disclaimer text")
  private lazy var dataProvider = ModelDataProvider.provider
  private lazy var workflowObject = dataProvider.cardApplication
  private var workflowAction: WorkflowAction {
    let action = dataProvider.workflowAction
    action.configuration = disclaimer

    return action
  }
  private lazy var disclaimerModule = serviceLocator.moduleLocatorFake.fullScreenDisclaimerModuleSpy

  override func setUp() {
    super.setUp()

    sut = ShowDisclaimerActionModule(serviceLocator: serviceLocator,
                                     workflowObject: workflowObject,
                                     workflowAction: workflowAction,
                                     actionConfirmer: ActionConfirmerFake.self)
  }

  func testInitializeAddFullScreenDisclaimerAsChild() {
    // When
    givenSUTInitialized()

    // Then
    XCTAssertTrue(disclaimerModule.initializeCalled)
    XCTAssertNotNil(disclaimerModule.onDisclaimerAgreed)
  }

  func testDisclaimerAgreedCallAcceptDisclaimer() {
    // Given
    givenSUTInitialized()
    let shiftCardSessionFake = serviceLocator.sessionFake.setUpShiftCardSession()

    // When
    disclaimerModule.onDisclaimerAgreed!(disclaimerModule) // swiftlint:disable:this force_unwrapping

    // Then
    XCTAssertTrue(shiftCardSessionFake.acceptDisclaimerCalled)
  }

  func testAgreedDisclaimerSucceedCallOnFinish() {
    // Given
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }
    givenSUTInitialized()
    givenSaveAgreementSucceed()
    // When
    disclaimerModule.onDisclaimerAgreed!(disclaimerModule) // swiftlint:disable:this force_unwrapping

    // Then
    XCTAssertTrue(onFinishCalled)
  }

  func testDisclaimerClosedShowConfirmation() {
    // Given
    givenSUTInitialized()

    // When
    disclaimerModule.close()

    // Then
    XCTAssertTrue(ActionConfirmerFake.confirmCalled)
  }

  func testDisclaimerCloseNotConfirmedDoNotClose() {
    // Given
    var onCloseCalled = false
    sut.onClose = { _ in
      onCloseCalled = true
    }
    givenSUTInitialized()
    ActionConfirmerFake.nextActionToExecute = .cancel

    // When
    disclaimerModule.close()

    // Then
    XCTAssertFalse(onCloseCalled)
  }

  func testDisclaimerCloseConfirmedCallCancelApplication() {
    // Given
    givenSUTInitialized()
    ActionConfirmerFake.nextActionToExecute = .ok
    let shiftCardSessionFake = serviceLocator.sessionFake.setUpShiftCardSession()

    // When
    disclaimerModule.close()

    // Then
    XCTAssertTrue(shiftCardSessionFake.cancelCardApplicationCalled)
    XCTAssertEqual(shiftCardSessionFake.lastCancelCardApplicationId, workflowObject.id)
  }

  func testDisclaimerCancelConfirmedCancelApplicationCallBack() {
    // Given
    var onCloseCalled = false
    sut.onClose = { _ in
      onCloseCalled = true
    }
    givenSUTInitialized()
    ActionConfirmerFake.nextActionToExecute = .ok
    let shiftCardSessionFake = serviceLocator.sessionFake.setUpShiftCardSession()
    shiftCardSessionFake.nextCancelCardApplicationResult = .success(Void())

    // When
    disclaimerModule.close()

    // Then
    XCTAssertTrue(onCloseCalled)
  }

  func testDisclaimerBackShowConfirmation() {
    // Given
    givenSUTInitialized()

    // When
    disclaimerModule.back()

    // Then
    XCTAssertTrue(ActionConfirmerFake.confirmCalled)
  }

  func testDisclaimerBackNotConfirmedDoNotBack() {
    // Given
    var onBackCalled = false
    sut.onBack = { _ in
      onBackCalled = true
    }
    givenSUTInitialized()
    ActionConfirmerFake.nextActionToExecute = .cancel

    // When
    disclaimerModule.back()

    // Then
    XCTAssertFalse(onBackCalled)
  }

  func testDisclaimerBackConfirmedCallCancelApplication() {
    // Given
    givenSUTInitialized()
    ActionConfirmerFake.nextActionToExecute = .ok
    let shiftCardSessionFake = serviceLocator.sessionFake.setUpShiftCardSession()

    // When
    disclaimerModule.back()

    // Then
    XCTAssertTrue(shiftCardSessionFake.cancelCardApplicationCalled)
    XCTAssertEqual(shiftCardSessionFake.lastCancelCardApplicationId, workflowObject.id)
  }

  func testDisclaimerBackConfirmedCancelApplicationCallBack() {
    // Given
    var onBackCalled = false
    sut.onBack = { _ in
      onBackCalled = true
    }
    givenSUTInitialized()
    ActionConfirmerFake.nextActionToExecute = .ok
    let shiftCardSessionFake = serviceLocator.sessionFake.setUpShiftCardSession()
    shiftCardSessionFake.nextCancelCardApplicationResult = .success(Void())

    // When
    disclaimerModule.back()

    // Then
    XCTAssertTrue(onBackCalled)
  }

  private func givenSUTInitialized() {
    sut.initialize { _ in }
  }

  private func givenSaveAgreementSucceed() {
    let shiftCardSessionFake = serviceLocator.sessionFake.setUpShiftCardSession()
    shiftCardSessionFake.nextAcceptDisclaimerResult = .success(Void())
  }
}
