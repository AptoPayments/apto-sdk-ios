//
//  FormRowLabelView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 31/01/16.
//
//

import UIKit

open class FormRowLabelView: FormRowView {
  let label: UILabel

  public init(label: UILabel,
              showSplitter: Bool,
              height: CGFloat = 44,
              position: PositionInRow = .center) {
    self.label = label
    super.init(showSplitter: showSplitter, height: height)
    self.contentView.snp.makeConstraints { make in
      make.height.equalTo(height)
    }
    self.layoutLabel(position: position)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func layoutLabel(position: PositionInRow) {
    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalTo(contentView)
      switch position {
      case .top:
        make.top.equalTo(contentView)
      case .center:
        make.centerY.equalTo(contentView)
      case .bottom:
        make.bottom.equalTo(contentView)
      }
    }
  }
}
