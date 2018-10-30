//
//  DataCollectorMemberOfArmedForcesStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 17/05/17.
//

import Bond

class MemberOfArmedForcesStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "member-of-armed-forces-collector.title".podLocalized()
  fileprivate let memberOfArmedForcesDataPoint: MemberOfArmedForces

  init(memberOfArmedForcesDataPoint: MemberOfArmedForces, uiConfig: ShiftUIConfig) {
    self.memberOfArmedForcesDataPoint = memberOfArmedForcesDataPoint
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
    let labelField = FormBuilder.labelLabelRowWith(leftText: "member-of-armed-forces-collector.subtitle".podLocalized(),
                                                   rightText: nil,
                                                   labelWidth: nil,
                                                   textAlignment: .left,
                                                   showSplitter: false,
                                                   uiConfig: uiConfig)
    guard let label = labelField.label else {
      return labelField
    }

    label.numberOfLines = 0
    label.font = uiConfig.fontProvider.formLabelFont
    label.textColor = uiConfig.textPrimaryColor
    return labelField
  }

  private func createRadioButtonField() -> FormRowRadioView {
    let labels = [
      "member-of-armed-forces-collector.yes".podLocalized(),
      "member-of-armed-forces-collector.no".podLocalized()
    ]
    let memberOfArmedForces = FormBuilder.radioRowWith(labels: labels, values: [0, 1], uiConfig: uiConfig)
    _ = memberOfArmedForces.bndValue.observeNext { [weak self] value in
      if let selectedValue = value {
        self?.memberOfArmedForcesDataPoint.memberOfArmedForces.next(selectedValue == 0)
      }
      else {
        self?.memberOfArmedForcesDataPoint.memberOfArmedForces.next(nil)
      }
    }
    if let value = self.memberOfArmedForcesDataPoint.memberOfArmedForces.value {
      memberOfArmedForces.bndValue.next(value == true ? 0 : 1)
    }
    else {
      memberOfArmedForces.bndValue.next(nil)
    }
    let failReasonMessage = "member-of-armed-forces-collector.time-at-address.warning.empty".podLocalized()
    memberOfArmedForces.numberValidator = NonNullIntValidator(failReasonMessage: failReasonMessage)
    validatableRows.append(memberOfArmedForces)
    return memberOfArmedForces
  }
}
