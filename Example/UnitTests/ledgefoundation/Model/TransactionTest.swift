//
//  ShiftSessionTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 20/08/2018.
//
//

import XCTest
@testable import ShiftSDK

class TransactionTest: XCTestCase {

  // MARK: - Transaction Class
  func testTransactionClassATM() {
    // When
    let sut = transactionWith(type: .withdrawal, state: .pending)

    // Then
    XCTAssertEqual(sut.transactionClass, TransactionClass.atm)
  }

  func testTransactionClassDeclined() {
    // When
    let sut = transactionWith(type: .decline, state: .pending)

    // Then
    XCTAssertEqual(sut.transactionClass, TransactionClass.declined)
  }

  func testTransactionClassPreauthorised() {
    // When
    let sut = transactionWith(type: .purchase, state: .pending)

    // Then
    XCTAssertEqual(sut.transactionClass, TransactionClass.preauthorised)
  }

  func testTransactionClassReversed() {
    // When
    let sut = transactionWith(type: .reversal, state: .authorized)

    // Then
    XCTAssertEqual(sut.transactionClass, TransactionClass.reversed)
  }

  func testTransactionClassAuthorised() {
    // When
    let sut = transactionWith(type: .purchase, state: .authorized)

    // Then
    XCTAssertEqual(sut.transactionClass, TransactionClass.authorised)
  }

  // MARK: - Device Type
  func testDeviceTypeEcommerce() {
    // When
    let sut = transactionWith(type: .withdrawal, state: .pending, ecommerce: true)

    // Then
    XCTAssertEqual(sut.deviceType, TransactionDeviceType.ecommerce)
  }

  func testDeviceTypeCardPresent() {
    // When
    let sut = transactionWith(type: .decline, state: .pending, cardPresent: true)

    // Then
    XCTAssertEqual(sut.deviceType, TransactionDeviceType.cardPresent)
  }

  func testDeviceTypeInternational() {
    // When
    let sut = transactionWith(type: .purchase, state: .pending, international: true)

    // Then
    XCTAssertEqual(sut.deviceType, TransactionDeviceType.international)
  }

  func testDeviceTypeEMV() {
    // When
    let sut = transactionWith(type: .reversal, state: .pending, emv: true)

    // Then
    XCTAssertEqual(sut.deviceType, TransactionDeviceType.emv)
  }

  func testDeviceTypeOther() {
    // When
    let sut = transactionWith(type: .purchase, state: .authorized)

    // Then
    XCTAssertEqual(sut.deviceType, TransactionDeviceType.other)
  }
}

private extension TransactionTest {
  func transactionWith(type: TransactionType,
                       state: TransactionState,
                       ecommerce: Bool? = nil,
                       cardPresent: Bool? = nil,
                       international: Bool? = nil,
                       emv: Bool? = nil) -> Transaction {
    return Transaction(transactionId: "",
                       transactionType: type,
                       createdAt: Date(),
                       externalTransactionId: nil,
                       transactionDescription: nil,
                       lastMessage: nil,
                       declineReason: nil,
                       merchant: nil,
                       store: nil,
                       localAmount: nil,
                       billingAmount: nil,
                       holdAmount: nil,
                       cashbackAmount: nil,
                       feeAmount: nil,
                       nativeBalance: nil,
                       settlement: nil,
                       ecommerce: ecommerce,
                       international: international,
                       cardPresent: cardPresent,
                       emv: emv,
                       cardNetwork: nil,
                       state: state,
                       adjustments: nil)
  }
}
