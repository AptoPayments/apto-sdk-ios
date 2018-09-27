//
//  ContentPresenterPresenter.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/09/2018.
//
//

import ReactiveKit

class ContentPresenterPresenter: ContentPresenterPresenterProtocol {
  let viewModel = ContentPresenterViewModel()
  var interactor: ContentPresenterInteractorProtocol! // swiftlint:disable:this implicitly_unwrapped_optional
  weak var router: ContentPresenterRouter! // swiftlint:disable:this implicitly_unwrapped_optional

  func viewLoaded() {
    interactor.provideContent { content in
      self.viewModel.content.next(content)
    }
  }

  func closeTapped() {
    router.close()
  }

  func linkTapped(_ url: URL) {
    router.show(url: url)
  }
}
