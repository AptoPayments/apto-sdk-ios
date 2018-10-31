//
//  ApplicationDetailsForm.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 24/08/16.
//
//

import Foundation

class ApplicationDetailsForm {

  let uiConfig: ShiftUIConfig
  let linkSession: LinkSession
  let loanData:AppLoanData
  let userData:DataPointList
  let dateFormatter: DateFormatter
  
  init(linkSession: LinkSession, userData:DataPointList, loanData:AppLoanData, uiConfig: ShiftUIConfig) {
    self.linkSession = linkSession
    self.uiConfig = uiConfig
    self.userData = userData
    self.loanData = loanData
    self.dateFormatter = DateFormatter.dateOnlyFormatter()
  }
  
  func setupRows() -> [FormRowView] {
    
    var rows = [FormRowView]()

    let moneyPattern = "$%d"

    let nameDataPoint = userData.nameDataPoint
    let emailDataPoint = userData.emailDataPoint
    let phoneDataPoint = userData.phoneDataPoint
    let addressDataPoint = userData.addressDataPoint
    let housingDataPoint = userData.housingDataPoint
    let incomeDataPoint = userData.incomeDataPoint
    let incomeSourcePoint = userData.incomeSourceDataPoint
    let birthDateDataPoint = userData.birthDateDataPoint
    let creditScoreDataPoint = userData.creditScoreDataPoint
    
    var grossMonthlyIncome: Int? = nil
    if incomeDataPoint.grossAnnualIncome.value != nil {
      grossMonthlyIncome = Int(incomeDataPoint.grossAnnualIncome.value!)
    }
    var netMonthlyIncome: Int? = nil
    if incomeDataPoint.netMonthlyIncome.value != nil {
      netMonthlyIncome = Int(incomeDataPoint.netMonthlyIncome.value!)
    }
    
    let phoneAsText = PhoneHelper.sharedHelper().formatPhoneWith(countryCode: phoneDataPoint.countryCode.value, nationalNumber: phoneDataPoint.phoneNumber.value)
    let birthdateAsText = birthDateDataPoint.date.value != nil ? dateFormatter.string(from:birthDateDataPoint.date.value! as Date) : ""

    rows.append(rowWith(leftText:"application-details.loan-purpose".podLocalized(), rightText:linkSession.loanPurposeDetails(loanPurposeId: loanData.purposeId.value)?.description ?? ""))
    rows.append(rowWith(leftText:"application-details.first-name".podLocalized(), rightText:nameDataPoint.firstName.value))
    rows.append(rowWith(leftText:"application-details.last-name".podLocalized(), rightText:nameDataPoint.lastName.value))
    rows.append(rowWith(leftText:"application-details.email".podLocalized(), rightText:emailDataPoint.email.value))
    rows.append(rowWith(leftText:"application-details.phone".podLocalized(), rightText:phoneAsText))
    rows.append(rowWith(leftText:"application-details.address".podLocalized(), rightText:addressDataPoint.address.value))
    rows.append(rowWith(leftText:"application-details.apt-unit".podLocalized(), rightText:addressDataPoint.apUnit.value))
    rows.append(rowWith(leftText:"application-details.city".podLocalized(), rightText:addressDataPoint.city.value))
    rows.append(rowWith(leftText:"application-details.state".podLocalized(), rightText:addressDataPoint.region.value))
    rows.append(rowWith(leftText:"application-details.zip-code".podLocalized(), rightText:addressDataPoint.zip.value))
    rows.append(rowWith(leftText:"application-details.housing-status".podLocalized(), rightText:housingDataPoint.housingType.value?.description ?? ""))
    rows.append(rowWith(leftText:"application-details.annual-pretax-income".podLocalized(), rightText:String(format: moneyPattern, arguments: [grossMonthlyIncome ?? 0])))
    rows.append(rowWith(leftText:"application-details.employment-status".podLocalized(), rightText:incomeSourcePoint.incomeType.value?.description ?? ""))
    rows.append(rowWith(leftText:"application-details.salary-frequency".podLocalized(), rightText:incomeSourcePoint.salaryFrequency.value?.description ?? ""))
    rows.append(rowWith(leftText:"application-details.monthly-net-income".podLocalized(), rightText:String(format: moneyPattern, arguments: [netMonthlyIncome ?? 0])))
    rows.append(rowWith(leftText:"application-details.credit-score".podLocalized(), rightText:creditScoreDataPoint.creditScoreRangeDescription() ?? ""))
    rows.append(rowWith(leftText:"application-details.birthday".podLocalized(), rightText:birthdateAsText))
    rows.append(rowWith(leftText:"application-details.SSN".podLocalized(), rightText:"*********"))

    return rows
  }
  
  fileprivate func rowWith(leftText:String, rightText:String?) -> FormRowLeftRightLabelView {
    return FormBuilder.labelLabelRowWith(leftText: leftText, rightText: rightText, uiConfig: uiConfig)
  }
}
