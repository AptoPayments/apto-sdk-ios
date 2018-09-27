//
//  TransactionListCellController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 20/03/16.
//
//

import Foundation

class TransactionListCellController: CellController {
  private let transaction: Transaction
  private let uiConfiguration: ShiftUIConfig

  init(transaction: Transaction, uiConfiguration: ShiftUIConfig) {
    self.transaction = transaction
    self.uiConfiguration = uiConfiguration
    super.init()
  }

  override func cellClass() -> AnyClass? {
    return TransactionListCell.classForCoder()
  }

  override func reuseIdentificator() -> String? {
    return NSStringFromClass(TransactionListCell.classForCoder())
  }

  override func setupCell(_ cell: UITableViewCell) {
    guard let cell = cell as? TransactionListCell else {
      return
    }
    cell.setUIConfiguration(uiConfiguration)
    cell.set(mcc: transaction.merchant?.mcc,
             amount: transaction.localAmount,
             transactionDescription: transaction.transactionDescription,
             date: transaction.createdAt)
    cell.cellController = self
  }
}
