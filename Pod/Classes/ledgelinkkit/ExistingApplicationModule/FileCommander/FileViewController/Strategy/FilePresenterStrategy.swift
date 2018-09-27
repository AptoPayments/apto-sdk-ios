//
//  FilePresenterStrategy.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 01/04/16.
//
//

import Foundation

protocol FilePresenterStrategy {
  func setup(_ viewModel: FileViewModel)
}

class FilePresenterStrategyFactory {
  static func strategyFor(file:File) -> FilePresenterStrategy {
    switch file.type {
    case .png:
      return FilePresenterStrategyPNG(file: file)
    case .pdf:
      return FilePresenterStrategyPDF(file: file)
    case .doc:
      return FilePresenterStrategyDOC(file: file)
    case .unknown:
      return FilePresenterStrategyUNKNOWN(file: file)
    }
  }
}
