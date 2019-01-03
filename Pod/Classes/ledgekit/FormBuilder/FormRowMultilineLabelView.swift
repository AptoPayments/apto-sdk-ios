//
//  FormRowMultilineLabelView.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 26/09/2018.
//

import SnapKit

open class FormRowMultilineLabelView: FormRowView {
  let label: UILabel

  public init(label: UILabel,
              height: CGFloat = 40,
              showSplitter: Bool = false) {
    self.label = label
    super.init(showSplitter: showSplitter, height: height)
    self.layoutLabel()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func layoutLabel() {
    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
