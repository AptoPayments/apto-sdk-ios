//
//  FormRowSwitchTitleSubtitleView.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 16/08/2018.
//
//

import SnapKit

class FormRowSwitchTitleSubtitleView: FormRowView {
  let titleSubtitleView: FormRowTopBottomLabelView
  let switcher: UISwitch

  init(titleLabel: UILabel,
       subtitleLabel: UILabel,
       switcher: UISwitch,
       height: CGFloat = 66) {
    self.switcher = switcher
    self.titleSubtitleView = FormRowTopBottomLabelView(titleLabel: titleLabel,
                                                       subtitleLabel: subtitleLabel,
                                                       height: height)
    super.init(showSplitter: false)

    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI() {
    layoutSwitch()
    layoutTitleView()
  }

  private func layoutSwitch() {
    addSubview(switcher)
    switcher.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().inset(16)
    }
  }

  private func layoutTitleView() {
    addSubview(titleSubtitleView)
    titleSubtitleView.snp.makeConstraints { make in
      make.left.top.bottom.equalToSuperview()
      make.right.equalTo(switcher.snp.left).inset(16)
    }
  }
}
