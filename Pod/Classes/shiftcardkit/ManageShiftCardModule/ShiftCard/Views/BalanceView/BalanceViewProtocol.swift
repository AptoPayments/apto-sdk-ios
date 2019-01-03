//
// Created by Takeichi Kanzaki on 2018-12-11.
//

import Foundation

protocol BalancePresentationProtocol {
  func set(fundingSource: FundingSource)
  func set(spendableToday: Amount?, nativeSpendableToday: Amount?)
}

typealias BalanceViewProtocol = UIView & BalancePresentationProtocol
