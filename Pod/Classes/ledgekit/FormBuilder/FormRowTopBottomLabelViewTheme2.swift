//
// FormRowTopBottomLabelViewTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 20/12/2018.
//

import SnapKit

class FormRowTopBottomLabelViewTheme2: FormRowView {
  private let titleLabel: UILabel
  private let subtitleLabel: UILabel?
  private let leftImageView: UIImageView?
  private let rightView: UIView?

  init(titleLabel: UILabel,
       subtitleLabel: UILabel? = nil,
       leftImageView: UIImageView? = nil,
       rightView: UIView? = nil,
       height: CGFloat = 72,
       clickHandler: (() -> Void)? = nil) {
    self.titleLabel = titleLabel
    self.subtitleLabel = subtitleLabel
    self.leftImageView = leftImageView
    self.rightView = rightView
    super.init(showSplitter: true, height: height)

    setUpUI()
    if let handler = clickHandler {
      addTapGestureRecognizer(action: handler)
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI() {
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
      offset = 10
    }
    layoutRightView()
    layoutLabelsRespectTo(leftConstraint: leftConstraint, offset: offset)
  }

  private func layoutImageView(_ imageView: UIImageView) {
    imageView.snp.makeConstraints { make in
      make.centerY.left.equalToSuperview()
      make.height.width.equalTo(32)
    }
  }

  private func layoutRightView() {
    guard let rightView = rightView else { return }
    contentView.addSubview(rightView)
    rightView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().inset(6)
    }
  }

  private func layoutLabelsRespectTo(leftConstraint: ConstraintItem, offset: CGFloat) {
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(leftConstraint).offset(offset)
      make.right.equalTo(rightConstraint).inset(16)
      if subtitleLabel != nil {
        make.top.equalToSuperview().offset(12)
      }
      else {
        make.centerY.equalToSuperview()
      }
    }
    guard let subtitleLabel = subtitleLabel else { return }
    contentView.addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
    }
  }

  private var rightConstraint: ConstraintItem {
    if let rightView = rightView {
      return rightView.snp.left
    }
    else {
      return contentView.snp.right
    }
  }
}
