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
                                     workflowAction: workflowAction)
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

  private func givenSUTInitialized() {
    sut.initialize { _ in }
  }

  private func givenSaveAgreementSucceed() {
    let shiftCardSessionFake = serviceLocator.sessionFake.setUpShiftCardSession()
    shiftCardSessionFake.nextAcceptDisclaimerResult = .success(Void())
  }
}
