//
//  FormRowSeparatorView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/02/16.
//
//

import UIKit

open class FormRowSeparatorView: FormRowView {
  public init(backgroundColor: UIColor,
              height: CGFloat,
              showTopLine: Bool = false,
              showBottomLine: Bool = false) {
    super.init(showSplitter: false,
               topPadding: 0,
               bottomPadding: 0,
               height: height,
               maxHeight: height)
    self.backgroundColor = backgroundColor
    if showTopLine {
      let topLine = UIView()
      self.addSubview(topLine)
      topLine.backgroundColor = colorize(0xd5d5d5, alpha: 1.0)
      topLine.snp.makeConstraints { make in
        make.left.right.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo(1 / UIScreen.main.scale);
      }
    }
    if showBottomLine {
      let bottomLine = UIView()
      self.addSubview(bottomLine)
      bottomLine.backgroundColor = colorize(0xd5d5d5, alpha: 1.0)
      bottomLine.snp.makeConstraints { make in
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.equalTo(1 / UIScreen.main.scale);
      }
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func becomeFirstResponder() -> Bool {
    return false
  }
}
