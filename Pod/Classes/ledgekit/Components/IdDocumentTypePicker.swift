//
//  IdDocumentTypePicker.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 09/10/2018.
//

import Bond
import ReactiveKit

class IdDocumentTypePicker: UIView {
  private let disposeBag = DisposeBag()
  let picker: UIPickerView
  var allowedDocumentTypes: [IdDocumentType] {
    didSet {
      picker.selectRow(0, inComponent: 0, animated: false)
      picker.reloadAllComponents()
      pickerView(picker, didSelectRow: 0, inComponent: 0)
    }
  }
  private var selectedType: IdDocumentType
  private let uiConfig: ShiftUIConfig

  init(allowedDocumentTypes: [IdDocumentType],
       selectedType: IdDocumentType? = nil,
       uiConfig: ShiftUIConfig) {
    guard let firstType = allowedDocumentTypes.first else {
      fatalError("At least one country is required")
    }
    self.uiConfig = uiConfig
    self.allowedDocumentTypes = allowedDocumentTypes
    self.picker = UIPickerView()
    self.selectedType = selectedType ?? firstType
    super.init(frame: .zero)

    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var _bndValue: Observable<IdDocumentType>?
  var bndValue: Observable<IdDocumentType> {
    if let bndValue = _bndValue {
      return bndValue
    }
    else {
      let bndValue = Observable<IdDocumentType>(selectedType)
      bndValue.observeNext { [weak self] (selectedType: IdDocumentType) in
        guard let self = self else { return }
        self.selectedType = selectedType
        if let selectedIndex = self.allowedDocumentTypes.index(where: { $0 == selectedType }) {
          self.picker.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
      }.dispose(in: disposeBag)
      _bndValue = bndValue
      return bndValue
    }
  }

  override var intrinsicContentSize: CGSize {
    return picker.intrinsicContentSize
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    picker.frame = bounds
  }
}

private extension IdDocumentTypePicker {
  func setUpUI() {
    // This is required for the view to get sized to the iOS keyboard size
    autoresizingMask = [.flexibleHeight, .flexibleWidth]
    addSubview(picker)
    picker.dataSource = self
    picker.delegate = self
  }
}

extension IdDocumentTypePicker: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return allowedDocumentTypes.count
  }
}

extension IdDocumentTypePicker: UIPickerViewDelegate {
  public func pickerView(_ pickerView: UIPickerView,
                         viewForRow row: Int,
                         forComponent component: Int,
                         reusing view: UIView?) -> UIView {
    let label: UILabel
    if let reusing = view as? UILabel {
      label = reusing
    }
    else {
      let horizontalMargin: CGFloat = 32
      label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width - 2 * horizontalMargin, height: 36))
    }
    label.textColor = uiConfig.textPrimaryColor
    label.font = uiConfig.formLabelFont
    label.text = allowedDocumentTypes[row].localizedDescription
    return label
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    bndValue.next(allowedDocumentTypes[row])
  }
}
