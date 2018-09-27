//
//  OfferDetailsForm.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/08/16.
//
//

import Foundation

class OfferDetailsForm {

  let uiConfig: ShiftUIConfig
  let offer: LoanOffer

  init(offer: LoanOffer, uiConfig: ShiftUIConfig) {
    self.offer = offer
    self.uiConfig = uiConfig
  }
  
  func setupRows() -> [FormRowView] {
    
    var retVal = [FormRowView]()
    
    if let interestRate = offer.interestRate {
      let interestRow = FormBuilder.labelLabelRowWith(leftText: "order-details-form.interest-rate".podLocalized(), rightText: "\(interestRate)%", uiConfig: uiConfig)
      interestRow.backgroundColor = uiConfig.cardBackgroundColor
      retVal.append(interestRow)
    }
    
    if let loanAmount = offer.loanAmount {
      let amountRow = FormBuilder.labelLabelRowWith(leftText: "order-details-form.amount-financed".podLocalized(), rightText: loanAmount.text, uiConfig: uiConfig)
      amountRow.backgroundColor = uiConfig.cardBackgroundColor
      retVal.append(amountRow)
    }

    if let paymentAmount = offer.paymentAmount, Int(paymentAmount.amount.value!) > 0 {
      let monthlyPaymentRow = FormBuilder.labelLabelRowWith(leftText: "order-details-form.monthly-payment".podLocalized(), rightText: paymentAmount.text, uiConfig: uiConfig)
      monthlyPaymentRow.backgroundColor = uiConfig.cardBackgroundColor
      retVal.append(monthlyPaymentRow)
    }
    
    if let term = offer.term, term.duration > 0 {
      let termRow = FormBuilder.labelLabelRowWith(leftText: "order-details-form.term".podLocalized(), rightText: term.text, showSplitter: false, uiConfig: uiConfig)
      termRow.backgroundColor = uiConfig.cardBackgroundColor
      retVal.append(termRow)
    }
    
    return retVal

  }
  
}
