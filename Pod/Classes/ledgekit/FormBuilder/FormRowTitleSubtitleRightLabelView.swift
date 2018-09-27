//
//  FormRowTitleSubtitleRightLabelView.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 16/08/2018.
//
//

import SnapKit

class FormRowTitleSubtitleRightLabelView: FormRowView {
  let titleLabel: UILabel
  let subtitleLabel: UILabel?
  let rightLabel: UILabel

  init(titleLabel: UILabel,
       subtitleLabel: UILabel?,
       rightLabel: UILabel,
       height: CGFloat = 66,
       clickHandler: (() -> Void)? = nil) {
    self.titleLabel = titleLabel
    self.subtitleLabel = subtitleLabel
    self.rightLabel = rightLabel
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
    layoutRightLabel()
    layoutLeftLabels()
  }

  private func layoutRightLabel() {
    addSubview(rightLabel)
    rightLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().inset(16)
    }
  }

  private func layoutLeftLabels() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.right.equalTo(rightLabel.snp.left).inset(16)
      if subtitleLabel == nil {
        make.centerY.equalToSuperview()
      }
      else {
        make.top.equalToSuperview().offset(12)
      }
    }
    guard let subtitleLabel = self.subtitleLabel else {
      return
    }
    addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
    }
  }
}
