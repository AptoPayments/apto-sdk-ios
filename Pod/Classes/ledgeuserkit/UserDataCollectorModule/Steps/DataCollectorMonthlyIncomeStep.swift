//
//  DataCollectorMonthlyIncomeStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond

class MonthlyIncomeStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "monthly-income-collector.title".podLocalized()
  private var incomeField: FormRowNumericSliderView! // swiftlint:disable:this implicitly_unwrapped_optional
  private let incomeDataPoint: Income

  init(incomeDataPoint: Income, uiConfig: ShiftUIConfig) {
    self.incomeDataPoint = incomeDataPoint
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    retVal.append(FormBuilder.separatorRow(height: 124))
    retVal.append(createLabelField())
    setUpIncomeField()
    retVal.append(incomeField)

    return retVal
  }

  func update(_ maxMonthlyIncome: Int) {
    self.incomeField.maximumValue = maxMonthlyIncome
  }

  private func createLabelField() -> FormRowLeftRightLabelView {
    let label = FormBuilder.labelLabelRowWith(leftText: "monthly-income-collector.subtitle".podLocalized(),
                                              rightText: nil,
                                              labelWidth: nil,
                                              textAlignment: .left,
                                              showSplitter: false,
                                              uiConfig: uiConfig)
    label.label?.font = uiConfig.fontProvider.formLabelFont
    label.label?.textColor = uiConfig.textPrimaryColor
    return label
  }

  private func setUpIncomeField() {
    let failReasonMessage = "monthly-income-collector.income.warning.empty".podLocalized()
    let validator = MinValueIntValidator(minValue: 0, failReasonMessage: failReasonMessage)
    self.incomeField = FormBuilder.sliderRowWith(text: "",
                                                 minimumValue: 0,
                                                 maximumValue: 5000,
                                                 textPattern: "$%d",
                                                 validator: validator,
                                                 accessibilityLabel: "Net Income Slider",
                                                 uiConfig: uiConfig)
    incomeDataPoint.netMonthlyIncome.bidirectionalBind(to: incomeField.bndNumber)
    incomeField.minStep = 100
    self.validatableRows = [incomeField]
  }
}
