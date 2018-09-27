//
//  ShowCardInfoAction.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 12/03/2018.
//

class ShowCardInfoAction {
  func run(completion: @escaping (Bool) -> Void) {
    let localAuthenticationHandler = LocalAuthenticationHandler()
    if localAuthenticationHandler.available() {
      localAuthenticationHandler.authenticate { result in
        DispatchQueue.main.async {
          switch result {
          case .failure:
            completion(false)
          case .success(let accessGranted):
            completion(accessGranted)
          }
        }
      }
    }
    else {
      // TODO: Fallback: What to do here? ATM, we just show the card info
      DispatchQueue.main.async {
        completion(true)
      }
    }
  }
}
