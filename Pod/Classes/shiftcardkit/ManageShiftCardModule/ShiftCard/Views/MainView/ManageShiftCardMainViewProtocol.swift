//
// ManageShiftCardMainViewProtocol.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-12-12.
//

import Foundation

protocol ManageShiftCardMainViewDelegate: class {
  func cardTapped()
  func cardSettingsTapped()
  func balanceTapped()
  func needToUpdateUI(action: () -> Void, completion: @escaping () -> Void)
  func activatePhysicalCardTapped()
}

enum TopMessageViewType: Int, Equatable {
  case none
  case invalidBalance
  case noBalance
  case activatePhysicalCard
}

protocol CardPresentationProtocol {
  func set(cardHolder: String?)
  func set(cardNumber: String?)
  func set(lastFour: String?)
  func set(cvv: String?)
  func set(cardNetwork: CardNetwork?)
  func set(expirationMonth: UInt, expirationYear: UInt)
  func set(fundingSource: FundingSource?)
  func set(physicalCardActivationRequired: Bool?, showMessage: Bool)
  func setSpendable(amount: Amount?, nativeAmount: Amount?)
  func set(cardState: FinancialAccountState?)
  func set(cardStyle: CardStyle?)
  func set(activateCardFeatureEnabled: Bool?)
  func set(showInfo: Bool?)
}

typealias ManageShiftCardMainViewProtocol = UIView & CardPresentationProtocol
