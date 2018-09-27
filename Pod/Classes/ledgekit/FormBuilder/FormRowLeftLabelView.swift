//
//  FormRowLeftLabelView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 07/02/16.
//
//

import UIKit

open class FormRowLeftLabelView: FormRowView {
  let label: UILabel?

  init(label: UILabel?,
       labelWidth: CGFloat?,
       showSplitter: Bool = false,
       height: CGFloat = 40) {
    self.label = label
    super.init(showSplitter: showSplitter, height: height)
    if let label = self.label {
      self.contentView.addSubview(label)
      label.snp.makeConstraints { make in
        if let labelWidth = labelWidth {
          make.width.equalTo(labelWidth)
        }
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(16);
      }
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func presentNonFocusedState() {
    guard let label = self.label else {
      return
    }
    UIView.transition(with: label, duration: 0.15, options: .transitionCrossDissolve, animations: {
      label.textColor = self.unfocusedColor
    }, completion: nil)
  }

  override func presentFocusedState() {
    guard let label = self.label else {
      return
    }
    UIView.transition(with: label, duration: 0.15, options: .transitionCrossDissolve, animations: {
      label.textColor = self.focusedColor
    }, completion: nil)
  }
}
