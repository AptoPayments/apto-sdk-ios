//
//  FormRowPhoneFieldView.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 03/10/2018.
//

import SnapKit
import Bond
import ReactiveKit

class FormRowPhoneFieldView: FormRowView {
  private let disposeBag = DisposeBag()
  let label: UILabel?
  let phoneTextField: PhoneTextFieldView
  var bndValue: Observable<InternationalPhoneNumber?> {
    return phoneTextField.bndValue
  }

  init(label: UILabel?, phoneTextField: PhoneTextFieldView, height: CGFloat, showSplitter: Bool = false) {
    self.label = label
    self.phoneTextField = phoneTextField
    super.init(showSplitter: showSplitter, height: height)
    setUpUI()
    linkValidation()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func becomeFirstResponder() -> Bool {
    return phoneTextField.becomeFirstResponder()
  }

  override func resignFirstResponder() -> Bool {
    return phoneTextField.resignFirstResponder()
  }

  private func linkValidation() {
    phoneTextField.isValid.observeNext { [unowned self] valid in
      self.valid.next(valid)
    }.dispose(in: disposeBag)
  }
}

private extension FormRowPhoneFieldView {
  func setUpUI() {
    layoutLabel()
    layoutPhoneTextField()
  }

  func layoutLabel() {
    guard let label = self.label else { return }
    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.top.equalToSuperview()
    }
  }

  private func layoutPhoneTextField() {
    contentView.addSubview(phoneTextField)
    phoneTextField.snp.makeConstraints { make in
      if let label = self.label {
        make.top.equalTo(label.snp.bottom).offset(6)
      }
      else {
        make.top.equalToSuperview()
      }
      make.left.right.bottom.equalToSuperview()
    }
  }
}
