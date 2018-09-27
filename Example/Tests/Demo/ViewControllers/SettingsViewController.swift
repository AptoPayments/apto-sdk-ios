//
//  SettingsViewController.swift
//  Ledge Demo
//
//  Created by Ivan Oliver on 01/25/2016.
//  Copyright (c) 2016 Ivan Oliver. All rights reserved.
//

import UIKit
import LedgeLink

class SettingsViewController: UIViewController {

  private struct Params {
    static let labelWidth: CGFloat = 120
    static let blueColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0)
  }

  private let formView: MultiStepForm = MultiStepForm()
  private var rows: [FormRowView]? = nil
  private let flatView = UIImageView(image: UIImage(named: "BackgroundImage"))
  private var manager: LedgeLink!
  private var applicationData: LoanApplication!
  private var flowConfiguration: LedgeLinkFlowConfig!

  convenience init (manager:LedgeLink, applicationData: LoanApplication, flowConfiguration: LedgeLinkFlowConfig) {
    self.init()
    self.manager = manager
    self.applicationData = applicationData
    self.flowConfiguration = flowConfiguration
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(self.formView)
    self.formView.snp_makeConstraints { make in
      make.top.left.right.bottom.equalTo(self.view)
    }
    self.formView.backgroundColor = UIColor.clearColor()

    self.title = "Settings"
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(SettingsViewController.cancelClicked))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(SettingsViewController.saveClicked))

    // UI Setup
    self.setupFormFields { [weak self] in
      guard let rows = self?.rows else {
        return
      }
      self?.flatView.backgroundColor = UIColor.redColor()
      var buildType = "Dev"
      if ALPHA_BUILD {
        buildType = "Alpha"
      }
      else if BETA_BUILD {
        buildType = "Beta"
      }
      else if RELEASE_BUILD {
        buildType = ""
      }
      self?.formView.show(rows: rows)
      self?.fillInDataFromInitialParameters()
      self?.newUserTokenReceived(self?.manager.userToken)

    }
  }

  @objc private func cancelClicked() {
    self.self.dismissViewControllerAnimated(true, completion:nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  private var amountField: FormRowTextInputView? = nil
  private var loanPurposeField: FormRowValuePickerView? = nil
  private var housingTypeField: FormRowValuePickerView? = nil
  private var employmentStatusField: FormRowValuePickerView? = nil
  private var salaryFrequencyField: FormRowValuePickerView? = nil
  private var firstNameField: FormRowTextInputView? = nil
  private var lastNameField: FormRowTextInputView? = nil
  private var emailField: FormRowTextInputView? = nil
  private var phoneField: FormRowTextInputView? = nil
  private var addressField: FormRowTextInputView? = nil
  private var aptUnitField: FormRowTextInputView? = nil
  private var cityField: FormRowTextInputView? = nil
  private var stateField: FormRowTextInputView? = nil
  private var zipField: FormRowTextInputView? = nil
  private var incomeField: FormRowTextInputView? = nil
  private var monthlyNetIncomeField: FormRowTextInputView? = nil
  private var creditScoreField: FormRowTextInputView? = nil
  private var birthdayField: FormRowDatePickerView? = nil
  private var tokenRow: FormRowTitleSubtitleView? = nil
  private var skipStepsRow: FormRowSwitchView? = nil
  private var strictAddressRow: FormRowSwitchView? = nil

  private func setupFormFields(completion:(Void->Void)) {
    let explanationRow = FormRowLabelView(label: self.explanationLabel("launcher.title.initial-values".localized()), showSplitter: false)
    self.amountField = FormRowTextInputView(label: self.label("launcher.amount".localized()), labelWidth: Params.labelWidth, textField: UITextField(), firstFormField: true)
    self.firstNameField = FormRowTextInputView(label: self.label("launcher.first-name".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.lastNameField = FormRowTextInputView(label: self.label("launcher.last-name".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.emailField = FormRowTextInputView(label: self.label("launcher.email".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.phoneField = FormRowTextInputView(label: self.label("launcher.phone".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.addressField = FormRowTextInputView(label: self.label("launcher.address".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.aptUnitField = FormRowTextInputView(label: self.label("launcher.apt-unit".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.cityField = FormRowTextInputView(label: self.label("launcher.city".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.stateField = FormRowTextInputView(label: self.label("launcher.state".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.zipField = FormRowTextInputView(label: self.label("launcher.zip-code".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.incomeField = FormRowTextInputView(label: self.label("launcher.income".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.monthlyNetIncomeField = FormRowTextInputView(label: self.label("launcher.monthly-income".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.creditScoreField = FormRowTextInputView(label: self.label("launcher.credit-score".localized()), labelWidth: Params.labelWidth, textField: UITextField())
    self.birthdayField = FormRowDatePickerView(label: self.label("launcher.birthday".localized()), labelWidth: Params.labelWidth, textField: UITextField(), date: NSDate(), format:.DateOnly)
    self.tokenRow = FormRowTitleSubtitleView(
      titleLabel:self.smallBoldLabel("launcher.user-token".localized()),
      subtitleLabel: self.smallLabel(" "),
      rightIcon:UIImage(named: "CloseIcon.png"),
      showSplitter: true) {
        self.manager.clearUserToken()
    }

    self.skipStepsRow = FormRowSwitchView(label: self.label("launcher.switch.skip-steps".localized()), labelWidth: Params.labelWidth, switcher: self.switcher())
    self.strictAddressRow = FormRowSwitchView(label: self.label("launcher.switch.address-check".localized()), labelWidth: Params.labelWidth, switcher: self.switcher())

    let doubleButtonRow = FormRowDoubleButtonView(leftButton: self.smallButton("launcher.button.clear-data".localized()), rightButton: self.smallButton("launcher.button.example-data".localized()), leftTapHandler: {
      self.clearData()
      }, rightTapHandler: {
        self.fillInData()
    })

    self.manager.loadConfigFromServer { result in
      switch result {
      case .Failure(let error):
        self.showError(error)
        break
      case .Success:

        var purposeValues = [FormValuePickerValue]()
        for loanPurpose in self.manager.availableLoanPurposes! { purposeValues.append(FormValuePickerValue(id:String(loanPurpose.loanPurposeId), text: loanPurpose.description)) }
        self.loanPurposeField = self.valuePickerRowWith(label: "launcher.purpose".localized(), placeholder: "launcher.purpose.placeholder".localized(), value: "", values: purposeValues)

        var housingTypeValues = [FormValuePickerValue]()
        for housingType in self.manager.availableHousingTypes! { housingTypeValues.append(FormValuePickerValue(id:String(housingType.housingTypeId), text: housingType.description)) }
        self.housingTypeField = self.valuePickerRowWith(label: "launcher.residence".localized(), placeholder: "", value: "", values: housingTypeValues)

        var employmentStatusValues = [FormValuePickerValue]()
        for employmentStatus in self.manager.availableEmploymentStatuses! { employmentStatusValues.append(FormValuePickerValue(id:String(employmentStatus.employmentStatusId), text: employmentStatus.description)) }
        self.employmentStatusField = self.valuePickerRowWith(label: "launcher.employment-status".localized(), placeholder: "", value: "", values: employmentStatusValues)

        var salaryFrequencyValues = [FormValuePickerValue]()
        for salaryFrequency in self.manager.availableSalaryFrequencies! { salaryFrequencyValues.append(FormValuePickerValue(id:String(salaryFrequency.salaryFrequencyId), text: salaryFrequency.description)) }
        self.salaryFrequencyField = self.valuePickerRowWith(label: "launcher.salary-frequency".localized(), placeholder: "", value: "", values: salaryFrequencyValues)

        self.rows = [explanationRow, self.amountField!, self.loanPurposeField!, self.firstNameField!, self.lastNameField!, self.emailField!, self.phoneField!, self.addressField!, self.aptUnitField!, self.cityField!, self.stateField!, self.zipField!, self.housingTypeField!, self.incomeField!, self.monthlyNetIncomeField!, self.employmentStatusField!, self.salaryFrequencyField!, self.creditScoreField!, self.birthdayField!, self.tokenRow!, self.skipStepsRow!, self.strictAddressRow!, doubleButtonRow]

        completion()
        break
      }
    }

  }

  func explanationLabel(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    label.textColor = UIColor.darkGrayColor()
    label.textAlignment = .Center
    return label
  }

  func label(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    return label
  }

  func smallBoldLabel(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont.boldSystemFontOfSize(12)
    return label
  }

  func smallLabel(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont.systemFontOfSize(12)
    return label
  }

  func button(text: String) -> UIButton {
    let button = UIButton()
    button.layer.masksToBounds = true
    button.layer.cornerRadius = 5
    button.clipsToBounds = true
    button.backgroundColor = Params.blueColor
    button.setTitle(text, forState: .Normal)
    return button
  }

  func smallButton(text: String) -> UIButton {
    let button = UIButton()
    button.layer.masksToBounds = true
    button.layer.cornerRadius = 5
    button.clipsToBounds = true
    button.backgroundColor = UIColor.lightGrayColor()
    button.setTitle(text, forState: .Normal)
    return button
  }

  func switcher() -> UISwitch {
    let switcher = UISwitch()
    switcher.onTintColor = Params.blueColor
    return switcher
  }

  func valuePickerRowWith(label label: String, placeholder:String, labelWidth: CGFloat? = nil, value:String?, values:[FormValuePickerValue], validator:DataValidator<String>? = nil) -> FormRowValuePickerView {
    let uilabel = self.label(label)
    let retVal = FormRowValuePickerView(label: uilabel, labelWidth: Params.labelWidth, textField: UITextField(), value: value, values: values, validator: validator)
    return retVal
  }

  @objc func saveClicked() {

    applicationData.loanData.amount = Amount(value:self.safeDouble(self.amountField!.textField.text), currency:"USD")
    applicationData.loanData.purposeId = self.safeInt(self.loanPurposeField!.selectedValue)
    applicationData.borrowerData.name.firstName = self.safeText(self.firstNameField!.textField.text)
    applicationData.borrowerData.name.lastName = self.safeText(self.lastNameField!.textField.text)
    applicationData.borrowerData.email = self.safeText(self.emailField!.textField.text)
    applicationData.borrowerData.phoneNumber.regionCode = "US"
    applicationData.borrowerData.phoneNumber.phoneNumber = self.safeText(self.phoneField!.textField.text)
    applicationData.borrowerData.birthday = self.birthdayField?.date
    applicationData.borrowerData.address.address = self.safeText(self.addressField!.textField.text)
    applicationData.borrowerData.address.apUnit = self.safeText(self.aptUnitField!.textField.text)
    applicationData.borrowerData.address.city = self.safeText(self.cityField!.textField.text)
    applicationData.borrowerData.address.stateCode = self.safeText(self.stateField!.textField.text)
    applicationData.borrowerData.address.zip = self.safeText(self.zipField!.textField.text)
    let housingTypeId = self.safeInt(self.housingTypeField!.selectedValue)
    applicationData.borrowerData.housingType = housingTypeId != nil ? LedgeLink.defaultManager().availableHousingTypes?.filter { $0.housingTypeId == housingTypeId }.first : nil
    applicationData.borrowerData.income = self.safeDouble(self.incomeField!.textField.text)
    applicationData.borrowerData.monthlyNetIncome = self.safeDouble(self.monthlyNetIncomeField!.textField.text)
    let employmentStatusId = self.safeInt(self.employmentStatusField!.selectedValue)
    applicationData.borrowerData.employmentStatus = employmentStatusId != nil ? LedgeLink.defaultManager().availableEmploymentStatuses?.filter { $0.employmentStatusId == employmentStatusId }.first : nil
    let salaryFrequencyId = self.safeInt(self.salaryFrequencyField!.selectedValue)
    applicationData.borrowerData.salaryFrequency = salaryFrequencyId != nil ? LedgeLink.defaultManager().availableSalaryFrequencies?.filter { $0.salaryFrequencyId == salaryFrequencyId }.first : nil
    applicationData.borrowerData.creditScore = self.safeInt(self.creditScoreField!.textField.text)

    flowConfiguration.uiConfig.formLabelTextFocusedColor = colorize(0x006837)
    flowConfiguration.uiConfig.formAuxiliarViewBackgroundColor = colorize(0xfafafa)
    flowConfiguration.uiConfig.formSliderHighlightedTrackColor = colorize(0x006837)
    flowConfiguration.uiConfig.formSliderValueTextColor = colorize(0x006837)
    flowConfiguration.uiConfig.tintColor = colorize(0x17a94f)
    flowConfiguration.uiConfig.offerApplyButtonTextColor = colorize(0x17a94f)
    flowConfiguration.uiConfig.disabledTintColor = colorize(0xa9a9a9)
    flowConfiguration.uiConfig.offerListStyle = .Carousel

    // Behavior configuration
    flowConfiguration.skipSteps = self.skipStepsRow?.switcher.on ?? false
    flowConfiguration.strictAddressValidation = self.strictAddressRow?.switcher.on ?? false
    //    flowConfiguration.GoogleGeocodingAPIKey = "[YOUR_GOOGLE_GEOCODING_KEY]"

    flowConfiguration.GoogleGeocodingAPIKey = "AIzaSyChG61EnKGAlmhP5tdd4RtE5s8Hpi8EOII"
    flowConfiguration.maxAmount = 25000
    flowConfiguration.amountIncrements = 500

    // Launch default UI
    self.self.dismissViewControllerAnimated(true, completion:nil)

  }

  private func fillInData() {
    self.amountField!.textField.text = "100"
    self.loanPurposeField!.selectedValue = "1"
    self.firstNameField!.textField.text = "John"
    self.lastNameField!.textField.text = "Smith"
    self.emailField!.textField.text = "john.smith@gmail.com"
    self.phoneField!.textField.text = "2015555555"
    self.addressField!.textField.text = "1310 Fillmore st"
    self.aptUnitField!.textField.text = "123"
    self.cityField!.textField.text = "San Francisco"
    self.stateField!.textField.text = "CA"
    self.zipField!.textField.text = "94115"
    self.housingTypeField!.selectedValue = "1"
    self.salaryFrequencyField!.selectedValue = "1"
    self.employmentStatusField!.selectedValue = "1"
    self.incomeField?.textField.text = "60000"
    self.monthlyNetIncomeField?.textField.text = "5000"
    self.creditScoreField?.textField.text = "2"
    guard let date = NSDate.dateFromJSONAPIFormat("2-8-1980") else {
      return
    }
    self.birthdayField?.date = date
  }

  private func fillInDataFromInitialParameters() {
    if let amount = self.applicationData.loanData.amount!.value {
      self.amountField!.textField.text = "\(amount)"
    }
    else {
      self.amountField!.textField.text = ""
    }
    self.loanPurposeField!.selectedValue = self.applicationData.loanData.purposeId != nil ? "\(self.applicationData.loanData.purposeId!)" : nil
    self.firstNameField!.textField.text = "\(self.applicationData.borrowerData.name.firstName ?? "")"
    self.lastNameField!.textField.text = "\(self.applicationData.borrowerData.name.lastName ?? "")"
    self.emailField!.textField.text = "\(self.applicationData.borrowerData.email ?? "")"
    self.phoneField!.textField.text = "\(self.applicationData.borrowerData.phoneNumber.phoneNumber ?? "")"
    self.addressField!.textField.text = "\(self.applicationData.borrowerData.address.address ?? "")"
    self.aptUnitField!.textField.text = "\(self.applicationData.borrowerData.address.apUnit ?? "")"
    self.cityField!.textField.text = "\(self.applicationData.borrowerData.address.city ?? "")"
    self.stateField!.textField.text = "\(self.applicationData.borrowerData.address.stateCode ?? "")"
    self.zipField!.textField.text = "\(self.applicationData.borrowerData.address.zip ?? "")"
    self.housingTypeField!.selectedValue = self.applicationData.borrowerData.housingType != nil ? "\(self.applicationData.borrowerData.housingType!.housingTypeId)" : nil
    self.salaryFrequencyField!.selectedValue = self.applicationData.borrowerData.salaryFrequency != nil ? "\(self.applicationData.borrowerData.salaryFrequency!.salaryFrequencyId)" : nil
    self.employmentStatusField!.selectedValue = self.applicationData.borrowerData.employmentStatus != nil ? "\(self.applicationData.borrowerData.employmentStatus!.employmentStatusId)" : nil
    if let income = self.applicationData.borrowerData.income {
      self.incomeField!.textField.text = "\(income)"
    }
    else {
      self.incomeField!.textField.text = ""
    }
    if let monthlyNetIncome = self.applicationData.borrowerData.monthlyNetIncome {
      self.monthlyNetIncomeField!.textField.text = "\(monthlyNetIncome)"
    }
    else {
      self.monthlyNetIncomeField!.textField.text = ""
    }
    self.creditScoreField?.textField.text = self.applicationData.borrowerData.creditScore != nil ? "\(self.applicationData.borrowerData.creditScore!)" : nil
    self.birthdayField?.date = self.applicationData.borrowerData.birthday != nil ? self.applicationData.borrowerData.birthday! : nil

    self.skipStepsRow?.switcher.on = flowConfiguration.skipSteps
    self.self.strictAddressRow?.switcher.on = flowConfiguration.strictAddressValidation

  }

  private func clearData() {
    self.amountField!.textField.text = ""
    self.loanPurposeField!.selectedValue = nil
    self.firstNameField!.textField.text = ""
    self.lastNameField!.textField.text = ""
    self.emailField!.textField.text = ""
    self.phoneField!.textField.text = ""
    self.addressField!.textField.text = ""
    self.aptUnitField!.textField.text = ""
    self.cityField!.textField.text = ""
    self.stateField!.textField.text = ""
    self.zipField!.textField.text = ""
    self.housingTypeField!.selectedValue = nil
    self.incomeField?.textField.text = ""
    self.monthlyNetIncomeField?.textField.text = ""
    self.employmentStatusField!.selectedValue = nil
    self.salaryFrequencyField!.selectedValue = nil
    self.creditScoreField?.textField.text = ""
    self.birthdayField?.date = nil
    self.formView.resignFirstResponder()
    self.skipStepsRow?.switcher.on = false
    self.self.strictAddressRow?.switcher.on = false
  }

  private func safeDouble(text: String?) -> Double? {
    guard let text = text else {
      return nil
    }
    return Double(text)
  }

  private func safeInt(text: String?) -> Int? {
    guard let text = text else {
      return nil
    }
    return Int(text)
  }

  private func safeText(text: String?) -> String? {
    guard let text = text else {
      return nil
    }
    return text.characters.count > 0 ? text : nil
  }

  private func colorize (hex: Int, alpha: Double = 1.0) -> UIColor {
    let red = Double((hex & 0xFF0000) >> 16) / 255.0
    let green = Double((hex & 0xFF00) >> 8) / 255.0
    let blue = Double((hex & 0xFF)) / 255.0
    return UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha) )
  }

}

extension SettingsViewController: LedgeLinkDelegate {

  func newUserTokenReceived(userToken:String?) {
    guard let tokenRow = self.tokenRow else {
      return
    }
    tokenRow.subtitleLabel.text = userToken
    tokenRow.showRightButton()
  }

  private func clearUserToken() {
    guard let tokenRow = self.tokenRow else {
      return
    }
    tokenRow.subtitleLabel.text = " "
    tokenRow.hideRightButton()
  }

}

extension SettingsViewController: LedgeLinkUIDelegate {

  func didFailShowingUserInterface(error:NSError) {
    hideBackgroundView()
    self.showError(error)
  }

  func didShowUserInterface() {
    showBackgroundView()
  }

  func didCloseUserInterface() {
    hideBackgroundView()
  }

  private func showBackgroundView() {
    self.view.addSubview(self.flatView)
    self.flatView.snp_makeConstraints { make in
      make.left.right.top.bottom.equalTo(self.view)
    }
    self.flatView.alpha = 0
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.flatView.alpha = 1
    })
  }

  private func hideBackgroundView() {
    UIView.animateWithDuration(0.3, animations: {
      self.flatView.alpha = 0
    }) { completed in
      self.flatView.removeFromSuperview()
    }
  }

  private func showError(error:NSError) {
    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
    self.presentViewController(alertController, animated: true, completion: nil)
  }

}

