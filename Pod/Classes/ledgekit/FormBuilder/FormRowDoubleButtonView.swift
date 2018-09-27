//
//  FormRowDoubleButtonView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 11/02/16.
//
//

import UIKit

open class FormRowDoubleButtonView: FormRowView {
  
  let leftButton: UIButton
  let rightButton: UIButton
  
  public init(leftButton: UIButton, rightButton: UIButton, leftTapHandler:@escaping ()->Void, rightTapHandler:@escaping ()->Void) {
    self.leftButton = leftButton
    self.rightButton = rightButton
    super.init(showSplitter: false)
    self.contentView.addSubview(self.leftButton)
    self.contentView.addSubview(self.rightButton)
    self.leftButton.snp.makeConstraints { make in
      make.left.equalTo(self.contentView);
      make.right.equalTo(self.rightButton.snp.left).offset(-10)
      make.top.equalTo(self.contentView).offset(10)
      make.bottom.equalTo(self.contentView).offset(-10)
    }
    self.rightButton.snp.makeConstraints { make in
      make.right.equalTo(self.contentView)
      make.top.equalTo(self.contentView).offset(10)
      make.bottom.equalTo(self.contentView).offset(-10)
      make.width.equalTo(self.leftButton.snp.width)
    }
    let _ = self.leftButton.reactive.tap.observeNext(with:leftTapHandler)
    let _ = self.rightButton.reactive.tap.observeNext(with:rightTapHandler)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
