//
//  FormRowLinkView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/02/16.
//
//

import UIKit

class FormRowLinkView: FormRowLeftLabelView {

  fileprivate let clickHandler: ()->Void

  init(label: UILabel?,
       leftIcon: UIImageView? = nil,
       leftIconMargin: CGFloat = 0,
       shadowedLabel: UILabel? = nil,
       showSplitter: Bool = true,
       showRightIcon: Bool = true,
       height: CGFloat = 44,
       clickHandler: @escaping () -> Void) {
    self.clickHandler = clickHandler
    super.init(label: label, labelWidth: nil, showSplitter: showSplitter, height: height)
    var rightIcon: UIImageView?
    if showRightIcon {
      rightIcon = UIImageView(image: UIImage.imageFromPodBundle("top_next_disabled.png"))
      self.contentView.addSubview(rightIcon!)
      rightIcon!.snp.makeConstraints { make in
        make.right.equalTo(self.contentView.snp.right).inset(15)
        make.centerY.equalTo(self.contentView)
      }
    }
    if leftIcon != nil {
      contentView.addSubview(leftIcon!)
      leftIcon!.snp.makeConstraints{ make in
        make.centerY.equalTo(self.contentView)
        make.left.equalTo(self.contentView).offset(leftIconMargin)
      }
      self.label?.snp.removeConstraints()
      self.label?.snp.makeConstraints{ make in
        make.left.equalTo(leftIcon!.snp.right).offset(15)
        make.centerY.equalTo(self.contentView);
      }
    }
    if shadowedLabel != nil {
      contentView.addSubview(shadowedLabel!)
      shadowedLabel!.snp.makeConstraints{ make in
        make.centerY.equalTo(contentView)
        if let rightIcon = rightIcon {
          make.right.equalTo(rightIcon.snp.left).offset(-15)
        }
        else {
          make.right.equalTo(self.contentView.snp.left).offset(-15)
        }
      }
    }
    self.padding = UIEdgeInsetsMake(self.padding.top, self.padding.left, self.padding.bottom, 0)
    self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                 action: #selector(FormRowLinkView.rowTapped)))
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func rowTapped() {
    clickHandler()
  }
}
