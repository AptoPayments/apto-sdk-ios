//
//  ViewWrapperCellController.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 03/09/2018.
//
//

import Foundation

class ViewWrapperCellController: CellController {
  private let view: UIView

  init(view: UIView) {
    self.view = view
    super.init()
  }

  override func cellClass() -> AnyClass? {
    return ViewWrapperCell.classForCoder()
  }

  override func reuseIdentificator() -> String? {
    return NSStringFromClass(ViewWrapperCell.classForCoder())
  }

  override func setupCell(_ cell: UITableViewCell) {
    guard let mainViewCell = cell as? ViewWrapperCell else {
      return
    }
    mainViewCell.set(view: view)
  }
}
