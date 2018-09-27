//
//  FormRowTopBottomLabelView.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 16/08/2018.
//
//

import SnapKit

class FormRowTopBottomLabelView: FormRowView {
  let titleLabel: UILabel
  let subtitleLabel: UILabel
  let leftImageView: UIImageView?

  init(titleLabel: UILabel,
       subtitleLabel: UILabel,
       leftImageView: UIImageView? = nil,
       height: CGFloat = 66,
       clickHandler: (() -> Void)? = nil) {
    self.titleLabel = titleLabel
    self.subtitleLabel = subtitleLabel
    self.leftImageView = leftImageView
    super.init(showSplitter: false, height: height)

    setUpUI()
    if let handler = clickHandler {
      addTapGestureRecognizer(action: handler)
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabel)
    let leftConstraint: ConstraintItem
    let offset: CGFloat
    if let imageView = leftImageView {
      contentView.addSubview(imageView)
      layoutImageView(imageView)
      leftConstraint = imageView.snp.right
      offset = 16
    }
    else {
      leftConstraint = contentView.snp.left
      offset = 0
    }
    layoutLabelRespectTo(leftConstraint: leftConstraint, offset: offset)
  }

  private func layoutImageView(_ imageView: UIImageView) {
    imageView.snp.makeConstraints { make in
      make.centerY.left.equalToSuperview()
      make.height.width.equalTo(32)
    }
  }

  private func layoutLabelRespectTo(leftConstraint: ConstraintItem, offset: CGFloat) {
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(leftConstraint).offset(offset)
      make.top.equalToSuperview().offset(12)
      make.right.equalToSuperview().inset(16)
    }
    subtitleLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
    }
  }
}
