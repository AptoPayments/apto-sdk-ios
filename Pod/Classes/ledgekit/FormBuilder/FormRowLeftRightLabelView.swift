//
//  FormRowLeftRightLabelView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 14/03/16.
//
//

import UIKit

class FormRowLeftRightLabelView: FormRowView {
  let label: UILabel?
  let rightLabel: UILabel?

  init(label: UILabel?,
       rightLabel: UILabel?,
       labelWidth: CGFloat? = nil,
       showSplitter: Bool = false) {
    self.label = label
    self.rightLabel = rightLabel
    super.init(showSplitter: showSplitter)
    if let label = self.label {
      self.contentView.addSubview(label)
      label.snp.makeConstraints { make in
        if let labelWidth = labelWidth {
          make.width.equalTo(labelWidth)
        }
        make.left.equalTo(self.contentView);
        make.top.bottom.equalTo(self.contentView);
      }
    }
    if let rightLabel = self.rightLabel {
      self.contentView.addSubview(rightLabel)
      rightLabel.snp.makeConstraints { make in
        if let leftLabel = self.label {
          make.left.equalTo(leftLabel.snp.right).offset(15);
        }
        else {
          make.left.equalTo(self.contentView)
        }
        make.right.equalTo(self.contentView)
        make.top.bottom.equalTo(self.contentView);
      }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
