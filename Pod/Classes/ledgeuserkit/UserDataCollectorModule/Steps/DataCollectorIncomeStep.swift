//
//  DataCollectorIncomeStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond

class IncomeStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "income-collector.title".podLocalized()
  private var incomeField: FormRowNumericSliderView! // swiftlint:disable:this implicitly_unwrapped_optional
  private var employmentStatusField: FormRowValuePickerView! // swiftlint:disable:this implicitly_unwrapped_optional
  private var salaryFrequencyField: FormRowValuePickerView! // swiftlint:disable:this implicitly_unwrapped_optional
  private let availableSalaryFrequencies: [SalaryFrequency]
  private let availableIncomeTypes: [IncomeType]
  private let userData: DataPointList
  private let requiredData: RequiredDataPointList
  private let showIncome: Bool
  private let showEmploymentStatus: Bool
  private let config: UserDataCollectorConfig

  init(requiredData: RequiredDataPointList,
       userData: DataPointList,
       availableSalaryFrequencies: [SalaryFrequency],
       availableIncomeTypes: [IncomeType],
       config: UserDataCollectorConfig,
       uiConfig: ShiftUIConfig) {
    self.userData = userData
    self.requiredData = requiredData
    self.showIncome = self.requiredData.getRequiredDataPointOf(type: .income) != nil
    self.showEmploymentStatus = self.requiredData.getRequiredDataPointOf(type: .incomeSource) != nil
    self.availableSalaryFrequencies = availableSalaryFrequencies
    self.availableIncomeTypes = availableIncomeTypes
    self.config = config
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    retVal.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 60))

    if showIncome {
      retVal.append(createIncomeLabel())
      setUpIncomeField()
      retVal.append(incomeField)
      validatableRows.append(incomeField)
    }

    if showEmploymentStatus {
      let incomeSourceDataPoint = userData.incomeSourceDataPoint
      setUpEmploymentStatusField(incomeSourceDataPoint: incomeSourceDataPoint)
      setUpSalaryFrequencyField(incomeSourceDataPoint: incomeSourceDataPoint)
      retVal.append(employmentStatusField)
      retVal.append(salaryFrequencyField)
      validatableRows.append(employmentStatusField)
      validatableRows.append(salaryFrequencyField)
    }

    return retVal
  }

  private func createIncomeLabel() -> FormRowLeftRightLabelView {
    let label = FormBuilder.labelLabelRowWith(leftText: "income-collector.subtitle".podLocalized(),
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
    let maxValue = config.grossIncomeRange.max
    let minValue = config.grossIncomeRange.min
    let validator = MinValueIntValidator(minValue: Int(minValue),
                                         failReasonMessage: "income-collector.income.warning.empty".podLocalized())
    self.incomeField = FormBuilder.sliderRowWith(text: "",
                                                 minimumValue: Int(minValue),
                                                 maximumValue: Int(maxValue),
                                                 textPattern: "$%d",
                                                 validator: validator,
                                                 accessibilityLabel: "Gross Income Slider",
                                                 uiConfig: uiConfig)
    let incomeDataPoint = userData.incomeDataPoint
    incomeDataPoint.grossAnnualIncome.bidirectionalBind(to: incomeField.bndNumber)
    incomeField.minStep = Int(config.grossIncomeRange.inc)
  }

  private func setUpEmploymentStatusField(incomeSourceDataPoint: IncomeSource) {
    let pickerValues = availableIncomeTypes.map { incomeType in
      // swiftlint:disable:next force_unwrapping
      return FormValuePickerValue(id: String(incomeType.incomeTypeId), text: incomeType.description!)
    }
    let placeholder = "income-collector.employment-status.placeholder".podLocalized()
    let failReasonMessage = "income-collector.employment-status.warning.empty".podLocalized()
    let validator = NonEmptyTextValidator(failReasonMessage: failReasonMessage)
    employmentStatusField = FormBuilder.valuePickerRowWith(label: "income-collector.employment-status".podLocalized(),
                                                           placeholder: placeholder,
                                                           value: "",
                                                           values: pickerValues,
                                                           validator: validator,
                                                           uiConfig: uiConfig)
    employmentStatusField.showSplitter = false
    if let incomeTypeId = incomeSourceDataPoint.incomeType.value?.incomeTypeId {
      employmentStatusField.bndValue.next(String(incomeTypeId))
    }
    else {
      employmentStatusField.bndValue.next(nil)
    }
    _ = employmentStatusField.bndValue.observeNext { employmentStatus in
      guard let employmentStatus = employmentStatus, let incomeTypeId = Int(employmentStatus) else {
        incomeSourceDataPoint.incomeType.next(nil)
        return
      }
      incomeSourceDataPoint.incomeType.next(IncomeType(incomeTypeId: incomeTypeId))
    }
  }

  private func setUpSalaryFrequencyField(incomeSourceDataPoint: IncomeSource) {
    let frequencyValues = availableSalaryFrequencies.map { salaryFrequency in
      // swiftlint:disable:next force_unwrapping
      return FormValuePickerValue(id: String(salaryFrequency.salaryFrequencyId), text: salaryFrequency.description!)
    }
    let placeholder = "income-collector.salary-frequency.placeholder".podLocalized()
    let failReasonMessage = "income-collector.salary-frequency.warning.empty".podLocalized()
    let validator = NonEmptyTextValidator(failReasonMessage: failReasonMessage)
    salaryFrequencyField = FormBuilder.valuePickerRowWith(label: "income-collector.salary-frequency".podLocalized(),
                                                          placeholder: placeholder,
                                                          value: "",
                                                          values: frequencyValues,
                                                          validator: validator,
                                                          uiConfig: uiConfig)
    salaryFrequencyField.showSplitter = false
    if let salaryFrequencyId = incomeSourceDataPoint.salaryFrequency.value?.salaryFrequencyId {
      salaryFrequencyField.bndValue.next(String(salaryFrequencyId))
    }
    else {
      salaryFrequencyField.bndValue.next(nil)
    }
    _ = salaryFrequencyField.bndValue.observeNext { salaryFrequency in
      guard let salaryFrequency = salaryFrequency, let salaryFrequencyId = Int(salaryFrequency) else {
        incomeSourceDataPoint.salaryFrequency.next(nil)
        return
      }
      incomeSourceDataPoint.salaryFrequency.next(SalaryFrequency(salaryFrequencyId: salaryFrequencyId))
    }
  }
}
