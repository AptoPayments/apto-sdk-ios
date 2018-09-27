//
//  Disclaimer.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 07/06/16.
//
//

import Foundation

open class LoanProduct {
  open var loanProductId: String
  open var productName: String
  open var prequalificationDisclaimer: Content?
  open var offerDisclaimer: Content?
  open var applicationDisclaimer: Content?
  open var esignDisclaimer: Content?
  open var esignConsentDisclaimer: Content?
  public init(loanProductId:String,
              productName:String,
              prequalificationDisclaimer:Content?,
              offerDisclaimer:Content?,
              applicationDisclaimer:Content?,
              esignDisclaimer:Content?,
              esignConsentDisclaimer:Content?) {
    self.loanProductId = loanProductId
    self.productName = productName
    self.prequalificationDisclaimer = prequalificationDisclaimer
    self.offerDisclaimer = offerDisclaimer
    self.applicationDisclaimer = applicationDisclaimer
    self.esignDisclaimer = esignDisclaimer
    self.esignConsentDisclaimer = esignConsentDisclaimer
  }
}
