//
//  LoanConsentInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/04/16.
//
//

import Foundation

class LinkLoanConsentInteractor: LinkLoanConsentInteractorProtocol {

  let application: LoanApplication
  let session: ShiftSession

  init(session: ShiftSession, application: LoanApplication) {
    self.session = session
    self.application = application
  }

  func loadApplicationData(_ completion:Result<LoanApplication, NSError>.Callback) {
    completion(.success(application))
  }

}
