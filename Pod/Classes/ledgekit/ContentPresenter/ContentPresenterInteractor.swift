//
//  ContentPresenterInteractor.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/09/2018.
//
//

class ContentPresenterInteractor: ContentPresenterInteractorProtocol {
  private let content: Content

  init(content: Content) {
    self.content = content
  }

  func provideContent(completion: (_ conent: Content) -> Void) {
    completion(content)
  }
}
