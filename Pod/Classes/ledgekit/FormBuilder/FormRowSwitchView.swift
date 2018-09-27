//
//  FormRowSwitchView.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 11/02/16.
//
//

import UIKit

open class FormRowSwitchView: FormRowLeftLabelView {
  public let switcher: UISwitch

  public init(label: UILabel?,
              labelWidth: CGFloat,
              switcher: UISwitch,
              showSplitter: Bool = true,
              height: CGFloat = 44) {
    self.switcher = switcher
    super.init(label: label, labelWidth: labelWidth, showSplitter: showSplitter, height: height)
    self.contentView.addSubview(self.switcher)
    self.switcher.snp.makeConstraints { make in
      make.right.equalTo(self.contentView)
      make.centerY.equalTo(self.contentView)
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
