//
//  FormRowTitleSubtitleView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 03/03/16.
//
//

import Foundation

open class FormRowTitleSubtitleView: FormRowView {
  public let titleLabel: UILabel
  public let subtitleLabel: UILabel
  let rightButton: UIButton
  let rightButtonTaHandler: (() -> Void)?

  public init(titleLabel: UILabel,
              subtitleLabel: UILabel,
              rightIcon: UIImage? = nil,
              showSplitter: Bool = false,
              rightButtonAccessibilityLabel: String? = nil,
              rightButtonTaHandler: (() -> Void)? = nil) {
    self.titleLabel = titleLabel
    self.subtitleLabel = subtitleLabel
    self.rightButton = UIButton(frame: CGRect.zero)
    self.rightButton.accessibilityLabel = rightButtonAccessibilityLabel
    self.rightButtonTaHandler = rightButtonTaHandler

    super.init(showSplitter: showSplitter)
    self.contentView.addSubview(self.titleLabel)
    self.titleLabel.snp.makeConstraints { make in
      make.left.right.top.equalTo(self.contentView)
    }
    self.contentView.addSubview(self.subtitleLabel)
    self.subtitleLabel.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(self.contentView)
      make.top.equalTo(self.titleLabel.snp.bottom)
    }
    guard let rightIcon = rightIcon else {
      return
    }
    self.rightButton.setImage(rightIcon, for: UIControlState())
    self.contentView.addSubview(self.rightButton)
    self.rightButton.isHidden = true
    self.rightButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.contentView)
      make.right.equalTo(self.contentView)
      make.width.height.equalTo(self.contentView.snp.height).multipliedBy(0.5)
    }
    self.rightButton.addTarget(self, action: #selector(FormRowTitleSubtitleView.rightButtonTapped), for: .touchUpInside)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func presentNonFocusedState() {
    UIView.transition(with: self.titleLabel,
                      duration: 0.15,
                      options: UIViewAnimationOptions.transitionCrossDissolve,
                      animations: {
                        self.titleLabel.textColor = self.unfocusedColor
                      },
                      completion: nil)
  }

  override func presentFocusedState() {
    UIView.transition(with: self.titleLabel,
                      duration: 0.15,
                      options: UIViewAnimationOptions.transitionCrossDissolve,
                      animations: {
                        self.titleLabel.textColor = self.focusedColor
                      },
                      completion: nil)
  }

  open func showRightButton() {
    self.rightButton.isHidden = false
  }

  open func hideRightButton() {
    self.rightButton.isHidden = true
  }

  @objc func rightButtonTapped() {
    self.rightButtonTaHandler?()
  }
}
