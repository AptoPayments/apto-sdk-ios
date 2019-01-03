//
// FormRowIdDocumentTypePickerView.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 09/10/2018.
//

import SnapKit
import Bond
import ReactiveKit

class FormRowIdDocumentTypePickerView: FormRowView {
  var allowedDocumentTypes: [IdDocumentType] {
    didSet {
      documentTypePicker.allowedDocumentTypes = self.allowedDocumentTypes
    }
  }
  private let disposeBag = DisposeBag()
  private let label: UILabel
  private let textField: UITextField
  private let uiConfig: ShiftUIConfig
  private let documentTypePicker: IdDocumentTypePicker
  private let height: CGFloat

  override var isEnabled: Bool {
    get {
      return super.isEnabled
    }
    set {
      super.isEnabled = newValue
      label.textColor = newValue ? uiConfig.textPrimaryColor : uiConfig.textPrimaryColorDisabled
      textField.isEnabled = newValue
      textField.textColor = newValue ? uiConfig.textSecondaryColor : uiConfig.textSecondaryColorDisabled
    }
  }

  init(label: UILabel,
       textField: UITextField,
       allowedDocumentTypes: [IdDocumentType],
       value: IdDocumentType? = nil,
       height: CGFloat = 80,
       uiConfig: ShiftUIConfig) {
    self.label = label
    self.textField = textField
    self.allowedDocumentTypes = allowedDocumentTypes
    self.uiConfig = uiConfig
    self.height = height
    self.documentTypePicker = IdDocumentTypePicker(allowedDocumentTypes: allowedDocumentTypes,
                                                   selectedType: value,
                                                   uiConfig: uiConfig)
    super.init(showSplitter: false, height: height)

    setUpUI()
    setUpObservers()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var bndValue: Observable<IdDocumentType> {
    return documentTypePicker.bndValue
  }
}

// MARK: - Reactive observers
private extension FormRowIdDocumentTypePickerView {
  func setUpObservers() {
    documentTypePicker.bndValue.observeNext { [unowned self] idDocumentType in
      var text = idDocumentType.localizedDescription
      if self.allowedDocumentTypes.count > 1 {
        text += " " + String.dropDownCharacter
      }
      self.textField.text = text
      self.valid.next(true)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension FormRowIdDocumentTypePickerView {
  func setUpUI() {
    backgroundColor = uiConfig.uiBackgroundPrimaryColor
    setUpLabel()
    setUpTextField()
  }

  func setUpLabel() {
    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.top.equalToSuperview().offset(16)
    }
  }

  func setUpTextField() {
    contentView.addSubview(textField)
    textField.snp.makeConstraints { make in
      make.top.equalTo(label.snp.bottom).offset(6)
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(height / 2)
    }
    textField.inputView = documentTypePicker
  }
}
