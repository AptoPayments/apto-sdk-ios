//
//  FilePresenterStrategyDOC.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 01/04/16.
//
//

import Foundation

class FilePresenterStrategyUNKNOWN: FilePresenterStrategy {
  
  let file: File
  
  init(file: File) {
    self.file = file
  }
  
  func setup(_ viewModel: FileViewModel) {
    viewModel.fullScreenImage.next(false)
    viewModel.fileName.next(self.file.name)
    viewModel.image.next(UIImage.imageFromPodBundle("DOC_File.png")!)
  }

}
