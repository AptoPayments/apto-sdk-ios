//
//  SelectFinancialAccountTypeInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/10/2016.
//
//

import Foundation

class SelectFinancialAccountTypeInteractor: SelectFinancialAccountTypeInteractorProtocol {
  
  let shiftSession: ShiftSession
  
  init(shiftSession:ShiftSession) {
    self.shiftSession = shiftSession
  }
  
  func issueVirtualCard(_ callback:@escaping Result<Card,NSError>.Callback) {
    shiftSession.issueCard (issuer:.shift, callback: callback)
  }

}
