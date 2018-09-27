//
//  LoanDataCollectorInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Foundation

protocol LinkLoanDataCollectorDataReceiver {
  func set(loanData: AppLoanData,
                    config: LinkLoanDataCollectorConfig)
}

class LinkLoanDataCollectorInteractor: LinkLoanDataCollectorInteractorProtocol {
  
  let dataReceiver: LinkLoanDataCollectorDataReceiver
  let loanData: AppLoanData
  let config: LinkLoanDataCollectorConfig
  
  init(loanData: AppLoanData,
       config: LinkLoanDataCollectorConfig,
       dataReceiver: LinkLoanDataCollectorDataReceiver) {
    self.dataReceiver = dataReceiver
    self.loanData = loanData
    self.config = config
  }
  
  func provideLoanDataCollectorData() {
    dataReceiver.set(loanData: loanData,
                     config: config)
  }

}
