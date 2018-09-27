//
//  DataCollectorCreditScoreStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond

class CreditScoreStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "credit-score-collector.title".podLocalized()
  fileprivate let creditScoreDataPoint: CreditScore
  fileprivate let availableCreditScoreOptions: [CreditScoreOption]

  init(creditScoreDataPoint: CreditScore, availableCreditScoreOptions: [CreditScoreOption], uiConfig: ShiftUIConfig) {
    self.creditScoreDataPoint = creditScoreDataPoint
    self.availableCreditScoreOptions = availableCreditScoreOptions
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    return [
      FormRowSeparatorView(backgroundColor: UIColor.clear, height: 124),
      createPicker()
    ]
  }

  private func createPicker() -> FormRowValuePickerView {
    let values = availableCreditScoreOptions.map {
      return FormValuePickerValue(id: String($0.creditScoreId), text: $0.description ?? "")
    }
    let failReasonMessage = "credit-score-collector.credit-score.warning.empty".podLocalized()
    let validator = NonEmptyTextValidator(failReasonMessage: failReasonMessage)
    let picker = FormBuilder.valuePickerRow(title: "credit-score-collector.subtitle".podLocalized(),
                                            selectedValue: nil,
                                            values: values,
                                            placeholder: "credit-score-collector.placeholder".podLocalized(),
                                            accessibilityLabel: "Time at address picker",
                                            validator: validator,
                                            uiConfig: uiConfig)
    _ = picker.bndValue.observeNext { [unowned self] creditScore in
      guard let creditScore = creditScore, let creditScoreId = Int(creditScore) else {
        self.creditScoreDataPoint.creditRange.next(nil)
        return
      }
      self.creditScoreDataPoint.creditRange.next(creditScoreId)
    }
    _ = picker.becomeFirstResponder()
    validatableRows.append(picker)
    return picker
  }
}
