//
//  PhysicalCardActivationSucceedInteractorTest.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//
//

import XCTest
@testable import ShiftSDK

class PhysicalCardActivationSucceedInteractorTest: XCTestCase {
  var sut: PhysicalCardActivationSucceedInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let card = ModelDataProvider.provider.cardWithIVR

  override func setUp() {
    super.setUp()

    sut = PhysicalCardActivationSucceedInteractor(card: card)
  }

  func testProvideCardCallbackCard() {
    // Given
    var returnedCard: Card?

    // When
    sut.provideCard { card in
      returnedCard = card
    }

    // Then
    XCTAssertEqual(returnedCard, card)
  }
}
