//
//  ViewWrapperCell.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 03/09/2018.
//
//

import UIKit
import SnapKit

class ViewWrapperCell: UITableViewCell {
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.selectionStyle = .none
  }

  func set(view: UIView) {
    contentView.addSubview(view)
    view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
