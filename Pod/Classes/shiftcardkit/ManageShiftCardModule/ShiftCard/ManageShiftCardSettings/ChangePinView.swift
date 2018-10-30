//
//  ChangePinView.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/03/2018.
//

import UIKit
import SnapKit

protocol ChangePinViewDelegate: class {
  func newCardPin(pin: String)
}

enum ChangePinViewState {
  case entryPin
  case confirmPin
}

class ChangePinView: UIView {
  private let uiConfig: ShiftUIConfig
  let backgroundView = UIView()
  var dialogView = UIView()
  weak var delegate: ChangePinViewDelegate?
  var state =  ChangePinViewState.entryPin
  private var descriptionLabel = UILabel()
  private var pinEntryView: UIPinEntryTextField! // swiftlint:disable:this implicitly_unwrapped_optional
  private var pin: String = ""

  init(uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
    super.init(frame: UIScreen.main.bounds)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func didTappedOnBackgroundView(){
    dismiss(animated: true)
  }
}

extension ChangePinView: Modal {
}

extension ChangePinView: UIPinEntryTextFieldDelegate {
  func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField) {
    switch state {
    case .entryPin:
      pin = frPinView.getText()
      pinEntryView.resetText()
      pinEntryView.focus()
      state = .confirmPin
      configureViewForCurrentState()
    case .confirmPin:
      let confirmedPin = frPinView.getText()
      guard confirmedPin == self.pin else {
        let error = UserError(message: "change.pin.error.pins-does-not-match".podLocalized())
        UIApplication.topViewController()?.show(error: error)
        pinEntryView.resetText()
        _ = pinEntryView.resignFirstResponder()
        pinEntryView.shake()
        state = .entryPin
        configureViewForCurrentState()
        return
      }
      self.delegate?.newCardPin(pin: pin)
    }
  }

  func pinEntryTextField(didDeletePin frPinView: UIPinEntryTextField) {
  }
}

private extension ChangePinView {
  func initialize(){
    setUpBackgroundView()
    setUpDialogView()
    let titleLabel = setUpTitleLabel()
    setUpDescriptionLabel(titleLabel: titleLabel)
    setUpPinEntryView()
  }

  func setUpBackgroundView() {
    backgroundView.backgroundColor = UIColor.black
    backgroundView.alpha = 0.6
    backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: #selector(didTappedOnBackgroundView)))
    addSubview(backgroundView)
    backgroundView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(self)
    }
  }

  func setUpDialogView() {
    dialogView.clipsToBounds = true
    dialogView.backgroundColor = UIColor.white
    dialogView.layer.cornerRadius = 6
    addSubview(dialogView)
    dialogView.snp.makeConstraints { make in
      make.width.equalTo(self).inset(32)
      make.centerX.equalTo(self)
      make.centerY.equalTo(self).offset(-80)
    }
  }

  func setUpTitleLabel() -> UILabel {
    let titleLabel = UILabel()
    titleLabel.text = "change.pin.title".podLocalized()
    titleLabel.font = uiConfig.fontProvider.amountBigFont
    titleLabel.textAlignment = .center
    titleLabel.textColor = uiConfig.textPrimaryColor
    dialogView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.centerX.equalTo(dialogView)
      make.left.right.equalTo(dialogView)
      make.top.equalTo(dialogView).offset(20)
      make.height.equalTo(30)
    }
    return titleLabel
  }

  func setUpDescriptionLabel(titleLabel: UIView) {
    descriptionLabel.font = uiConfig.fontProvider.formListFont
    descriptionLabel.textAlignment = .center
    descriptionLabel.textColor = uiConfig.textSecondaryColor
    descriptionLabel.numberOfLines = 0
    dialogView.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.centerX.equalTo(dialogView)
      make.left.right.equalTo(dialogView).inset(8)
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
    }
  }

  func setUpPinEntryView() {
    pinEntryView = UIPinEntryTextField(size: 4, frame: CGRect.zero, accessibilityLabel: "Card PIN")
    pinEntryView.showMiddleSeparator = false
    pinEntryView.delegate = self
    dialogView.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
      make.centerX.equalTo(dialogView)
      make.width.equalTo(160)
      make.height.equalTo(40)
      make.bottom.equalTo(dialogView.snp.bottom).offset(-24)
    }

    configureViewForCurrentState()
    pinEntryView.resetText()
    pinEntryView.focus()
  }

  func configureViewForCurrentState() {
    switch state {
    case .entryPin:
      descriptionLabel.text = "change.pin.type-pin".podLocalized()
    case .confirmPin:
      descriptionLabel.text = "change.pin.type-pin.confirm".podLocalized()
    }
  }
}
