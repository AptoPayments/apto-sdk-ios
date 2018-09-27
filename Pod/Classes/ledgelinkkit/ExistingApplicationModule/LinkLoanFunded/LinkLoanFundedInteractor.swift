//
//  LinkLoanFundedInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/11/2016.
//
//

import Foundation

protocol LinkLoanFundedDataReceiver {
}

class LinkLoanFundedInteractor: LinkLoanFundedInteractorProtocol {

  let linkSession: LinkSession
  let application: LoanApplication
  let dataReceiver: LinkLoanFundedDataReceiver

  init(linkSession: LinkSession, application: LoanApplication, dataReceiver:LinkLoanFundedDataReceiver) {
    self.linkSession = linkSession
    self.application = application
    self.dataReceiver = dataReceiver
  }

  func loadApplicationData(_ completion: @escaping Result<LoanApplication, NSError>.Callback) {
    completion(.success(self.application))
  }

}
