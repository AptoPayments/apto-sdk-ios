//
//  ProgressView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 03/06/16.
//
//

import SnapKit

class ProgressView: UIView {
  private let uiConfig: ShiftUIConfig
  private let maxValue: Float
  private let progressView: UIView
  var currentValue: Float = 0
  var foregroundColor: UIColor {
    didSet {
      self.progressView.backgroundColor = foregroundColor
    }
  }

  init(maxValue: Float, uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
    self.maxValue = maxValue
    self.progressView = UIView(frame: CGRect.zero)
    self.progressView.translatesAutoresizingMaskIntoConstraints = false
    self.foregroundColor = uiConfig.uiSecondaryColor
    super.init(frame: CGRect.zero)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.backgroundColor = uiConfig.uiSecondaryColorDisabled
    self.progressView.backgroundColor = self.foregroundColor
    self.addSubview(progressView)
    progressView.snp.makeConstraints { make in
      make.left.top.bottom.equalTo(self)
      make.width.equalTo(0)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(progress: Float) {
    guard progress >= 0 && progress <= maxValue else {
      return
    }
    currentValue = progress
    UIView.animate(withDuration: 0.4) {
      self.progressView.snp.remakeConstraints { make in
        make.left.top.bottom.equalTo(self)
        make.width.equalTo(self).multipliedBy(self.currentValue / self.maxValue)
      }
      self.layoutIfNeeded()
    }
  }
}
