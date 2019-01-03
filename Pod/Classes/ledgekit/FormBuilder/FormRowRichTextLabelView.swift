//
//  FormRowRichTextLabelView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 09/06/16.
//
//

import UIKit
import SnapKit
import TTTAttributedLabel

open class FormRowRichTextLabelView: FormRowView {
  let label: TTTAttributedLabel
  let linkHandler: LinkHandler?

  public init(label: TTTAttributedLabel,
              showSplitter: Bool,
              height: CGFloat = 44,
              position: PositionInRow = .center,
              linkHandler: LinkHandler? = nil) {
    self.label = label
    self.label.delegate = linkHandler
    self.linkHandler = linkHandler
    super.init(showSplitter: showSplitter, height: height)
    self.layoutLabel(position: position)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func layoutLabel(position: PositionInRow) {
    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalTo(contentView)
      switch position {
      case .top:
        make.top.equalTo(contentView)
      case .center:
        make.top.equalTo(contentView)
        make.bottom.equalTo(contentView)
      case .bottom:
        make.bottom.equalTo(contentView)
      }
    }
  }
}
