//
//  FileCommanderPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 31/03/16.
//
//

import Bond

protocol FileCommanderPresenterProcotol {
  var viewModel: FileCommanderViewModel { get }
  func viewLoaded()
  func nextFileTapped()
  func previousFileTapped()
  func didShow(_ file:Int)
  func deleteFileTapped(_ file:Int)
}

protocol FileCommanderDelegate {
  func fileDeleted(_ file:File)
}

protocol FileViewControllerBuilder {
  func prepareFileViewController(_ file:File) -> FileViewController
}

class FileCommanderViewModel {
  var files: Observable<[File]?> = Observable(nil)
  var title: Observable<String> = Observable("")
}

class FileCommanderPresenter: FileCommanderPresenterProcotol {
  
  let folderName:String
  let uiConfiguration: ShiftUIConfig
  let viewModel = FileCommanderViewModel()
  var interactor: FileCommanderInteractorProtocol!
  var view: FileCommanderViewControllerProtocol!
  var title: String?
  var delegate: FileCommanderDelegate?
  fileprivate var currentFile: Int = 0
  
  init(uiConfiguration: ShiftUIConfig, folderName:String) {
    self.uiConfiguration = uiConfiguration
    self.folderName = folderName
    let _ = NotificationCenter.default.reactive.notification(name: NSNotification.Name(rawValue: "LinkFileUploaded"), object: nil).observeNext { [weak self] notification in
      self?.buildContents()
    }
  }

  func viewLoaded() {
    buildContents()
  }
  
  func nextFileTapped() {
    view.showNextFile()
  }
  
  func previousFileTapped() {
    view.showPreviousFile()
  }
  
  func didShow(_ file:Int) {
    currentFile = file
    viewModel.title.next(currentTitle())
  }
  
  func deleteFileTapped(_ file:Int) {
    guard let files = viewModel.files.value else {
      return
    }
    guard file < files.count else {
      return
    }
    let fileToDelete = files[file]
    interactor.delete(file: fileToDelete, folderName: folderName)
    buildContents()
    delegate?.fileDeleted(fileToDelete)
  }
  
  fileprivate func currentTitle() -> String {
    
    let fileCount = viewModel.files.value?.count ?? 0
    let title = self.title ?? "Files"
    let fileCountString = "(\(currentFile + 1)/\(fileCount))"
    
    if fileCount > 1 {
      return "\(title) \(fileCountString)"
    }
    else {
      return title
    }
  }
  
  fileprivate func buildContents() {
    interactor.loadFileList(folderName, completion: { [weak self] files in
      if files?.count == 0 {
        self?.view.previousTapped()
        return
      }
      self?.viewModel.files.next(files)
      guard let newTitle = self?.currentTitle() else {
        self?.viewModel.title.next("")
        return
      }
      self?.viewModel.title.next(newTitle)
      })
  }
  
}

extension FileCommanderPresenter: FileViewControllerBuilder {
  
  func prepareFileViewController(_ file:File) -> FileViewController {
    
    let presenter = FilePresenter(file:file)
    let viewController = FileViewController(uiConfiguration: uiConfiguration, presenter: presenter)
    let interactor = FileInteractor()
    
    presenter.view = viewController
    presenter.interactor = interactor
    
    return viewController
    
  }
}

class FileCommanderFactory {
  
  static func fileCommander(_ uiConfiguration: ShiftUIConfig, folderName: String, title:String? = nil, delegate:FileCommanderDelegate? = nil) -> FileCommanderViewController {
    
    let presenter = FileCommanderPresenter(uiConfiguration: uiConfiguration, folderName:folderName)
    let interactor = FileCommanderInteractor()
    presenter.interactor = interactor
    presenter.title = title
    presenter.delegate = delegate
    
    let viewController = FileCommanderViewController(uiConfiguration: uiConfiguration,
                                                     presenter: presenter,
                                                     fileViewControllerBuilder: presenter)
    presenter.view = viewController
    
    return viewController
    
  }
  
}
