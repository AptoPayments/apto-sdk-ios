//
//  DataCollectorAmountStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond

class LinkLoanDataColletorAmountStep: DataCollectorBaseStep, DataCollectorStepProtocol {

  var title = "amount-collector.title".podLocalized()

  fileprivate let getOffersTapHandler:()->Void
  fileprivate let showPendingApplicationsTapHandler:()->Void
  fileprivate let linkHandler: LinkHandler?
  fileprivate let loanData: AppLoanData
  fileprivate let config: LinkLoanDataCollectorConfig
  fileprivate let showLoanAmount: Bool
  fileprivate let showLoanPurpose: Bool
  fileprivate var getOffersButton: FormRowButtonView?

  var amountField: FormRowNumericSliderView!
  var loanReasonField: FormRowValuePickerView!

  init(loanData:AppLoanData,
       config: LinkLoanDataCollectorConfig,
       uiConfig:ShiftUIConfig,
       getOffersTapHandler:@escaping ()->Void,
       showPendingApplicationsTapHandler:@escaping ()->Void,
       linkHandler:LinkHandler?) {
    self.config = config
    self.loanData = loanData
    self.getOffersTapHandler = getOffersTapHandler
    self.showPendingApplicationsTapHandler = showPendingApplicationsTapHandler
    self.linkHandler = linkHandler
    self.showLoanAmount = self.config.requiredLoanAmount
    self.showLoanPurpose = self.config.requiredLoanPurpose
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {

    let maxValue = config.loanAmountRange.max
    let minValue = config.loanAmountRange.min

    var rows: [FormRowView] = []

    rows.append(self.stepSubtitleRowWith(text: "amount-collector.subtitle".podLocalized()))
    rows.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 1, showBottomLine: true))

    if self.showLoanAmount {
      amountField = FormBuilder.sliderRowWith(text: "",
                                             minimumValue: Int(minValue),
                                             maximumValue: Int(maxValue),
                                             textPattern: "$%d",
                                             validator: MinValueIntValidator(minValue: Int(minValue), failReasonMessage: "amount-collector.amount.warning.empty".podLocalized()),
                                             accessibilityLabel:"Loan Amount Slider",
                                             uiConfig: uiConfig)
      if let loanAmount = loanData.amount {
        self.amountField.bndNumber.next(Int(loanAmount.amount.value!))
      }
      let _ = amountField.bndNumber.observeNext { amountValue in
        self.loanData.amount?.amount.next(Double(amountValue!))
      }
      amountField.minStep = Int(config.loanAmountRange.inc)
      amountField.setupComplete = true
      amountField.trackHighlightTintColor = self.uiConfig.tintColor
      amountField.trackTintColor = self.uiConfig.formSliderTrackColor
      rows.append(amountField)
      self.validatableRows.append(amountField)
    }

    if self.showLoanPurpose {

      if self.showLoanAmount {
        rows.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 1, showBottomLine:true))
      }

      let pickerValues: [FormValuePickerValue] = self.config.loanPurposes.map { (loanPurpose:LoanPurpose) -> FormValuePickerValue in
        return FormValuePickerValue(id:String(loanPurpose.loanPurposeId), text: loanPurpose.description)
      }

      loanReasonField = FormBuilder.valuePickerRowWith(label: "amount-collector.purpose".podLocalized(),
                                                       placeholder: "amount-collector.purpose.placeholder".podLocalized(),
                                                       value: "",
                                                       values: pickerValues,
                                                       accessibilityLabel: "Loan Purpose Picker",
                                                       validator: NonEmptyTextValidator(failReasonMessage: "amount-collector.purpose.warning.empty".podLocalized()),
                                                       uiConfig: self.uiConfig)
      loanReasonField.showSplitter = false
      if loanData.purposeId.value != nil {
        loanReasonField.bndValue.next(String(loanData.purposeId.value!))
      }
      let _ = loanReasonField.bndValue.observeNext { purpose in
        guard let purpose = purpose else {
          self.loanData.purposeId.next(nil)
          return
        }
        self.loanData.purposeId.next(Int(purpose))
      }

      rows.append(loanReasonField)
      self.validatableRows.append(loanReasonField)

    }

    rows.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 1, showTopLine: true))

    if config.mode == .finalStep {

      getOffersButton = FormBuilder.buttonRowWith(
        title: "amount-collector.button.get-offers".podLocalized(),
        accessibilityLabel: "Get Offers Button",
        tapHandler: self.handleGetOffesButtonClick,
        uiConfig: self.uiConfig)

      rows.append(getOffersButton!)

      if !config.pendingApplications.isEmpty {
        let message = "amount-collector.there-are-pending-applications".podLocalized().replace(["(%count%)":"\(config.pendingApplications.count)"])
        let pendingApplicationsButton = FormBuilder.textButtonRowWith(title: message, tapHandler: self.showPendingApplicationsTapHandler, uiConfig: self.uiConfig)
        rows.append(pendingApplicationsButton)
      }

      let privateInfoLabel = FormBuilder.itemDescriptionRowWith(
        text: "amount-collector.private-information".podLocalized(),
        uiConfig: self.uiConfig)
      rows.append(privateInfoLabel)

      let textPrequalificationDisclaimers = config.loanProducts
        .map { $0.prequalificationDisclaimer }
        .filter { $0 != nil ? $0!.isPlainText : false} as! [Content]

      let disclosureText = textPrequalificationDisclaimers.reduce(nil) { (src, disclaimer) -> NSAttributedString? in
        let optDisclosureString = disclaimer.attributedString(font: uiConfig.fonth6,
                                                              color: uiConfig.noteTextColor,
                                                              linkColor: uiConfig.tintColor)
        guard let disclosureString = optDisclosureString else {
          return src
        }
        guard src != nil else {
          return disclosureString
        }
        let retVal = NSMutableAttributedString(string: "\n\n")
        retVal.append(disclosureString)
        return retVal
      }

      if let richText = disclosureText, richText.string != "" {
        let disclousureTitle = "\n\n" + "amount-collector.disclosures".podLocalized() + "\n\n"
        let titledDisclosures = NSMutableAttributedString.createFrom(string: disclousureTitle,
                                                                     font: uiConfig.fonth6,
                                                                     color: uiConfig.noteTextColor)
        titledDisclosures.append(richText)
        let disclosureLabel = FormBuilder.richTextNoteRowWith(text: titledDisclosures,
                                                              textAlignment: .left,
                                                              position: .top,
                                                              uiConfig: uiConfig,
                                                              linkHandler: self.linkHandler)
        disclosureLabel.label.numberOfLines = 0

        rows.append(disclosureLabel)
      }
    }

    return rows
  }

  fileprivate func handleGetOffesButtonClick() {
    if self.loanReasonField != nil {
      _ = self.loanReasonField.resignFirstResponder()
    }
    if self.amountField != nil {
      _ = self.amountField.resignFirstResponder()
    }
    self.getOffersTapHandler()
  }

  override func setupStepValidation() {

    super.setupStepValidation()

    if config.mode == .finalStep {
      guard let getOffersButton = self.getOffersButton else { return }
      let _ = self.valid.observeNext { [weak self] valid in
        getOffersButton.button.isEnabled = valid
        if valid == true {
          getOffersButton.button.backgroundColor = self?.self.uiConfig.tintColor
        }
        else {
          getOffersButton.button.backgroundColor = self?.self.uiConfig.disabledTintColor
        }
      }
    }
  }

}
