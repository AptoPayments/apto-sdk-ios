//
//  FilePresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 31/03/16.
//
//

import Bond

protocol FilePresenterProtocol {
  var viewModel: FileViewModel { get }
  func viewLoaded()
}

class FileViewModel {
  let fileName: Observable<String?> = Observable(nil)
  let image: Observable<UIImage?> = Observable(nil)
  let fullScreenImage: Observable<Bool> = Observable(false)
}

class FilePresenter: FilePresenterProtocol {
  
  let file: File
  let viewModel = FileViewModel()
  var interactor: FileInteractor!
  var strategy: FilePresenterStrategy!
  var view: FileViewController!

  init(file:File) {
    self.file = file
    self.strategy = FilePresenterStrategyFactory.strategyFor(file: file)
  }
  
  func viewLoaded() {
    self.strategy.setup(self.viewModel)
  }
  
}
