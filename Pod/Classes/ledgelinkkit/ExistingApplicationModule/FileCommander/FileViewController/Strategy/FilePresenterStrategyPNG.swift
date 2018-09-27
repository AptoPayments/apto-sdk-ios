//
//  FilePresenterStrategyPNG.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 01/04/16.
//
//

import Foundation

class FilePresenterStrategyPNG: FilePresenterStrategy {
  
  let file: File
  
  init(file: File) {
    self.file = file
  }
  
  func setup(_ viewModel: FileViewModel) {
    guard let data = self.file.data else {
      viewModel.fullScreenImage.next(false)
      viewModel.fileName.next("file.camera-capture".podLocalized())
      return
    }
    viewModel.fullScreenImage.next(true)
    viewModel.fileName.next(nil)
    viewModel.image.next(UIImage(data: data))
  }
  
}
