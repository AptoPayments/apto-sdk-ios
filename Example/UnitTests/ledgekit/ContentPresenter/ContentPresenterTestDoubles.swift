//
//  ContentPresenterTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/09/2018.
//
//

@testable import ShiftSDK

class ContentPresenterModuleSpy: UIModuleSpy, ContentPresenterModuleProtocol {
  private(set) var showURLCalled = false
  func show(url: URL) {
    showURLCalled = true
  }
}

class ContentPresenterInteractorSpy: ContentPresenterInteractorProtocol {
  private(set) var provideContentCalled = false
  func provideContent(completion: (_ content: Content) -> Void) {
    provideContentCalled = true
  }
}

class ContentPresenterInteractorFake: ContentPresenterInteractorSpy {
  var nextContentToProvide: Content?
  override func provideContent(completion: (_ content: Content) -> Void) {
    super.provideContent(completion: completion)

    guard let content = nextContentToProvide else {
      return
    }
    completion(content)
  }
}

class ContentPresenterPresenterSpy: ContentPresenterPresenterProtocol {
  let viewModel = ContentPresenterViewModel()
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: ContentPresenterInteractorProtocol!
  var router: ContentPresenterRouter!
  // swiftlint:enable implicitly_unwrapped_optional

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var linkTappedCalled = false
  private(set) var lastURLTapped: URL?
  func linkTapped(_ url: URL) {
    linkTappedCalled = true
    lastURLTapped = url
  }
}
