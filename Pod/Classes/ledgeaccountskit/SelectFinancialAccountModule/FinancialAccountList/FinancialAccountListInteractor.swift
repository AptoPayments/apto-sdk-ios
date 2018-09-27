//
//  FinancialAccountListInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 17/10/2016.
//
//

import Foundation

class FinancialAccountListInteractor: FinancialAccountListInteractorProtocol {
  
  let shiftSession: ShiftSession
  
  init(shiftSession:ShiftSession) {
    self.shiftSession = shiftSession
  }
  
  func loadFinancialAccountList(_ callback:@escaping Result<[FinancialAccount],NSError>.Callback) {
    shiftSession.nextFinancialAccounts(0, rows: Int.max, callback: callback)
  }
  
}
