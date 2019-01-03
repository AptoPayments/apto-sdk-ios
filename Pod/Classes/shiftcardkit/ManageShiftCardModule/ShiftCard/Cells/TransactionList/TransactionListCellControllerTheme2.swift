//
// TransactionListCellControllerTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-12-14.
//

import Foundation

class TransactionListCellControllerTheme2: CellController {
  private let transaction: Transaction
  private let uiConfiguration: ShiftUIConfig
  private var cell: TransactionListCellTheme2?

  var isLastCellInSection: Bool = false {
    didSet {
      cell?.isLastCellInSection = isLastCellInSection
    }
  }

  init(transaction: Transaction, uiConfiguration: ShiftUIConfig) {
    self.transaction = transaction
    self.uiConfiguration = uiConfiguration
    super.init()
  }

  override func cellClass() -> AnyClass? {
    return TransactionListCellTheme2.classForCoder()
  }

  override func reuseIdentificator() -> String? {
    return NSStringFromClass(TransactionListCellTheme2.classForCoder())
  }

  override func setupCell(_ cell: UITableViewCell) {
    guard let cell = cell as? TransactionListCellTheme2 else {
      return
    }
    self.cell = cell
    cell.setUIConfiguration(uiConfiguration)
    cell.set(mcc: transaction.merchant?.mcc,
             amount: transaction.localAmount,
             nativeAmount: transaction.nativeBalance,
             transactionDescription: transaction.transactionDescription,
             date: transaction.createdAt)
    cell.cellController = self
  }
}

