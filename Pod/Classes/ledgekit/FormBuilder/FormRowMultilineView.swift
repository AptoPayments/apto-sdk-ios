//
//  FormRowMultilineView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 27/02/16.
//
//

import UIKit

class FormRowMultilineView: FormRowView {

  let flashColor: UIColor?
  var lines: [UIView] = []

  init(showSplitter:Bool = false, flashColor: UIColor?) {
    self.flashColor = flashColor
    super.init(showSplitter: showSplitter, topPadding: 0, bottomPadding: 0, leftPadding: 0, rightPadding: 0, height: 44)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  func add(lines:[UIView]) {
    var lastLine: UIView? = nil
    for line in lines {
      self.add(line: line, afterLine: lastLine)
      lastLine = line
    }
    lastLine?.snp.makeConstraints { make in
      make.bottom.equalTo(self.contentView.snp.bottom)
    }
  }

  func add(line:UIView, afterLine: UIView?, separatorOffset:CGFloat = 20) {
    if afterLine != nil {
      let separatorView = UIView()
      self.addSubview(separatorView)
      separatorView.snp.makeConstraints{ make in
        make.top.equalTo(afterLine != nil ? afterLine!.snp.bottom : self.contentView.snp.top)
        make.left.equalTo(self.contentView).offset(separatorOffset)
        make.right.equalTo(self.contentView).offset(-separatorOffset)
        make.height.equalTo(1 / UIScreen.main.scale)
      }
      separatorView.backgroundColor = colorize(0xefefef, alpha:1.0)
    }
    self.contentView.addSubview(line)
    line.snp.makeConstraints { make in
      make.left.right.equalTo(self.contentView)
      make.top.equalTo(afterLine != nil ? afterLine!.snp.bottom : self.contentView.snp.top)
    }
    line.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FormRowMultilineView.lineTapped(_:))))
    self.lines.append(line)
  }

  @objc func lineTapped(_ gestureRecognizer:UIGestureRecognizer) {
    return
  }

}
