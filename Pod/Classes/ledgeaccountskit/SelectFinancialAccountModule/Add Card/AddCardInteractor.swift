//
//  AddCardInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 20/10/2016.
//
//

import Foundation

class AddCardInteractor: AddCardInteractorProtocol {
  
  let shiftSession: ShiftSession
  
  init(shiftSession:ShiftSession) {
    self.shiftSession = shiftSession
  }
  
  func cardHolderName(_ callback:@escaping Result<String?,NSError>.Callback) {
    shiftSession.currentUser { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
        break
      case .success(let currentUser):
        callback(.success(currentUser.userData.nameDataPoint.fullName()))
      }
    }
  }
  
  func addCard(cardNumber:String, cardNetwork:CardNetwork, expirationMonth:UInt, expirationYear:UInt, cvv:String, callback:@escaping Result<Card,NSError>.Callback) {
    shiftSession.addCard(cardNumber: cardNumber, cardNetwork:cardNetwork, expirationMonth: expirationMonth, expirationYear:expirationYear, cvv: cvv, callback:callback)
  }  
  
}
