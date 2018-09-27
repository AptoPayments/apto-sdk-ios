//
//  UITableView.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 19/03/2018.
//

import UIKit
import SnapKit

extension UITableView {
  /// Set table header view & layout constraints.
  func setTableHeaderView(headerView: UIView) {
    self.tableHeaderView = headerView
    headerView.snp.makeConstraints { make in
      make.top.left.right.width.equalTo(self)
    }
  }
}
