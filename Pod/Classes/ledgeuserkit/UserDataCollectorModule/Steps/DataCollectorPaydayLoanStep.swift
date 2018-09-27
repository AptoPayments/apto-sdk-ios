//
//  DataCollectorPaydayLoanStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 17/05/17.
//

import Bond

class PaydayLoanStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "payday-loan-collector.title".podLocalized()
  fileprivate let paydayLoanDataPoint:PaydayLoan

  init(paydayLoanDataPoint: PaydayLoan, uiConfig: ShiftUIConfig) {
    self.paydayLoanDataPoint = paydayLoanDataPoint
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    retVal.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 124))
    retVal.append(createQuestionLabel())
    retVal.append(createRadioButtonField())
    return retVal
  }

  private func createQuestionLabel() -> FormRowLeftRightLabelView {
    let labelField = FormBuilder.labelLabelRowWith(leftText: "payday-loan-collector.subtitle".podLocalized(),
                                                   rightText: nil,
                                                   labelWidth: nil,
                                                   textAlignment: .left,
                                                   showSplitter: false,
                                                   uiConfig: uiConfig)
    guard let label = labelField.label else {
      return labelField
    }

    label.numberOfLines = 0
    label.font = uiConfig.formLabelFont
    label.textColor = uiConfig.textPrimaryColor
    return labelField
  }

  private func createRadioButtonField() -> FormRowRadioView {
    let labels = [
      "payday-loan-collector.yes".podLocalized(),
      "payday-loan-collector.no".podLocalized()
    ]
    let paydayLoan = FormBuilder.radioRowWith(labels: labels, values: [0, 1], uiConfig: uiConfig)
    _ = paydayLoan.bndValue.observeNext { [weak self] value in
      if let selectedValue = value {
        self?.paydayLoanDataPoint.usedPaydayLoan.next(selectedValue == 0)
      }
      else {
        self?.paydayLoanDataPoint.usedPaydayLoan.next(nil)
      }
    }
    if let value = self.paydayLoanDataPoint.usedPaydayLoan.value {
      paydayLoan.bndValue.next(value == true ? 0 : 1)
    }
    else {
      paydayLoan.bndValue.next(nil)
    }
    let failReasonMessage = "payday-loan-collector.time-at-address.warning.empty".podLocalized()
    paydayLoan.numberValidator = NonNullIntValidator(failReasonMessage: failReasonMessage)
    validatableRows.append(paydayLoan)
    return paydayLoan
  }
}
