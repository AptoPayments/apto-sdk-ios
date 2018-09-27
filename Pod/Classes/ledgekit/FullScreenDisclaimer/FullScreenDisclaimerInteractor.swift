//
//  FullScreenDisclaimerInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 13/10/2016.
//
//

import Foundation

class FullScreenDisclaimerInteractor: FullScreenDisclaimerInteractorProtocol {
  private let disclaimer: Content

  init(disclaimer: Content) {
    self.disclaimer = disclaimer
  }

  func provideDisclaimer(completion: @escaping((_ disclaimer: Content) -> Void)) {
    completion(disclaimer)
  }
}
