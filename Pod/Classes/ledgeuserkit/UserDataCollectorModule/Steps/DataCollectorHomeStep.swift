//
//  DataCollectorAddressStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond
import ReactiveKit

class HomeStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "home-collector.title".podLocalized()
  private var housingTypeField: FormRowValuePickerView! // swiftlint:disable:this implicitly_unwrapped_optional
  private let requiredData: RequiredDataPointList
  private let userData: DataPointList
  private let availableHousingTypes: [HousingType]

  init(requiredData: RequiredDataPointList,
       userData: DataPointList,
       availableHousingTypes: [HousingType],
       uiConfig: ShiftUIConfig) {
    self.userData = userData
    self.requiredData = requiredData
    self.availableHousingTypes = availableHousingTypes
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    retVal.append(FormBuilder.separatorRow(height: 124))

    setUpHousingField()
    _ = housingTypeField.becomeFirstResponder()
    retVal.append(housingTypeField)

    return retVal
  }

  override func setupStepValidation() {
    housingTypeField.valid.bind(to: self.valid)
  }

  private func setUpHousingField() {
    let values: [FormValuePickerValue] = self.availableHousingTypes.map { housingType in
      // swiftlint:disable:next force_unwrapping
      return FormValuePickerValue(id: String(housingType.housingTypeId), text: housingType.description!)
    }
    let placeholder = "home-collector.residence.placeholder".podLocalized()
    let validator = NonEmptyTextValidator(failReasonMessage: "home-collector.residence.warning.empty".podLocalized())
    self.housingTypeField = FormBuilder.valuePickerRowWith(label: "home-collector.residence".podLocalized(),
                                                           placeholder: placeholder,
                                                           value: "",
                                                           values: values,
                                                           accessibilityLabel: "Home Type Picker",
                                                           validator: validator,
                                                           uiConfig: uiConfig)
    housingTypeField.showSplitter = false
    let housingDataPoint = userData.housingDataPoint
    if let housingTypeId = housingDataPoint.housingType.value?.housingTypeId {
      housingTypeField.bndValue.next(String(housingTypeId))
    }
    else {
      housingTypeField.bndValue.next(nil)
    }
    _ = housingTypeField.bndValue.observeNext { housingType in
      guard let housingType = housingType, let housingTypeId = Int(housingType) else {
        housingDataPoint.housingType.next(nil)
        return
      }
      housingDataPoint.housingType.next(HousingType(housingTypeId: housingTypeId))
    }
  }
}
