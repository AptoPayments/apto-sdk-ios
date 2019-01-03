//
//  FormRowLeftImageRightLabelView.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 14/08/2018.
//

import UIKit

class FormRowLeftImageRightLabelView: FormRowView {
  let imageView: UIImageView?
  let rightLabel: UILabel?

  init(imageView: UIImageView?, rightLabel: UILabel?, showSplitter: Bool = false, height: CGFloat = 40) {
    self.imageView = imageView
    self.rightLabel = rightLabel
    super.init(showSplitter: showSplitter, height: height)
    setupUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension FormRowLeftImageRightLabelView {
  private func setupUI() {
    if let imageView = self.imageView {
      self.contentView.addSubview(imageView)
      imageView.snp.makeConstraints { make in
        make.left.equalTo(self.contentView)
        make.top.equalTo(self.contentView).offset(4)
      }
    }
    if let rightLabel = self.rightLabel {
      self.contentView.addSubview(rightLabel)
      rightLabel.snp.makeConstraints { make in
        if let imageView = self.imageView {
          make.left.equalTo(imageView.snp.right).offset(16)
        }
        else {
          make.left.equalTo(self.contentView)
        }
        make.right.equalTo(self.contentView)
        make.top.bottom.equalTo(self.contentView)
      }
    }
  }
}
