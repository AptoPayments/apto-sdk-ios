//
//  DataCollectorTimeAtAddressStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 17/05/17.
//

import Bond

class TimeAtAddressStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "time-at-address-collector.title".podLocalized()
  fileprivate let timeAtAddressDataPoint: TimeAtAddress
  fileprivate let availableTimeAtAddressOptions: [TimeAtAddressOption]

  init(timeAtAddressDataPoint: TimeAtAddress,
       availableTimeAtAddressOptions: [TimeAtAddressOption],
       uiConfig: ShiftUIConfig) {
    self.timeAtAddressDataPoint = timeAtAddressDataPoint
    self.availableTimeAtAddressOptions = availableTimeAtAddressOptions
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    return [
      FormRowSeparatorView(backgroundColor: UIColor.clear, height: 124),
      createPicker()
    ]
  }

  private func createPicker() -> FormRowValuePickerView {
    let values = availableTimeAtAddressOptions.map {
      return FormValuePickerValue(id: String($0.timeAtAddressId), text: $0.description ?? "")
    }
    let failReasonMessage = "time-at-address-collector.time-at-address.warning.empty".podLocalized()
    let validator = NonEmptyTextValidator(failReasonMessage: failReasonMessage)
    let picker = FormBuilder.valuePickerRow(title: "time-at-address-collector.subtitle".podLocalized(),
                                            selectedValue: nil,
                                            values: values,
                                            placeholder: "time-at-address-collector.placeholder".podLocalized(),
                                            accessibilityLabel: "Time at address picker",
                                            validator: validator,
                                            uiConfig: uiConfig)
    _ = picker.bndValue.observeNext { [unowned self] timeAtAddress in
      guard let timeAtAddress = timeAtAddress, let timeAtAddressId = Int(timeAtAddress) else {
        self.timeAtAddressDataPoint.timeAtAddress.next(nil)
        return
      }
      self.timeAtAddressDataPoint.timeAtAddress.next(TimeAtAddressOption(timeAtAddressId: timeAtAddressId))
    }
    _ = picker.becomeFirstResponder()
    validatableRows.append(picker)
    return picker
  }
}
