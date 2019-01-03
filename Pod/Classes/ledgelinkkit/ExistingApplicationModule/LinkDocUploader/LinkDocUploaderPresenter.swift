//
//  DocUploaderPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 24/03/16.
//
//

import Bond

protocol LinkDocUploaderRouterProtocol {
  func back(_ animated: Bool)
}

protocol LinkDocUploaderInteractorProtocol {
  func loadRequiredDocuments()
  func store(fileForRequiredDocument requiredDocument:UIRequiredDocument, file:LinkFile)
  func delete(fileForRequiredDocument requiredDocument:UIRequiredDocument, file:LinkFile)
  func upload(callback:Result<LoanApplication,NSError>.Callback)
  func folderFor(requiredDocument:RequiredDocument) -> String
}

protocol LinkDocUploaderViewProtocol: ViewControllerProtocol {
  func showUploadingState()
  func activateNavNextButton(_ tintColor:UIColor?)
  func deactivateNavNextButton(_ disabledTintColor:UIColor?)
  func presentFileCommander(_ fileCommander:FileCommanderViewController)
}

class DocUploaderViewModel {
  let requiredDocuments: Observable<[RequiredDocumentViewModel]?> = Observable(nil)
}

class RequiredDocumentViewModel {
  let uiRequiredDocument: UIRequiredDocument
  let enabledIcon: UIImage
  let disabledIcon: UIImage
  let docName: Observable<String>
  init (uiRequiredDocument:UIRequiredDocument, enabledIcon:UIImage, disabledIcon:UIImage, docName:String) {
    self.uiRequiredDocument = uiRequiredDocument
    self.enabledIcon = enabledIcon
    self.disabledIcon = disabledIcon
    self.docName = Observable(docName)
  }
}

class DocUploaderPresenter: LinkDocUploaderEventHandlerProtocol, LinkDocUploaderDataReceiver {

  let uiConfiguration: ShiftUIConfig
  var view: LinkDocUploaderViewProtocol!
  var router: LinkDocUploaderRouterProtocol!
  var interactor: LinkDocUploaderInteractorProtocol!
  let viewModel = DocUploaderViewModel()

  init(uiConfiguration: ShiftUIConfig) {
    self.uiConfiguration = uiConfiguration
    let _ = NotificationCenter.default.reactive.notification(name: NSNotification.Name(rawValue: "LinkFileUploaded"), object: nil).observeNext { [weak self] notification in
      self?.interactor.loadRequiredDocuments()
    }
  }

  // MARK: - DocUploaderPresenterProtocol

  func viewLoaded() {
    interactor.loadRequiredDocuments()
  }

  func addFile(_ file:LinkFile, requiredDocument:RequiredDocumentViewModel) {
    interactor.store(fileForRequiredDocument: requiredDocument.uiRequiredDocument, file: file)
    interactor.loadRequiredDocuments()
  }

  func closeTapped() {
    router.back(true)
  }

  func nextTapped() {
    uploadDocuments()
  }

  func presentFileCommanderFor(_ requiredDocument:RequiredDocumentViewModel) {
    let fileCommander = FileCommanderFactory.fileCommander(
      uiConfiguration,
      folderName: interactor.folderFor(requiredDocument: requiredDocument.uiRequiredDocument.requiredDocument),
      title: requiredDocument.docName.value,
      delegate: self)
    view.presentFileCommander(fileCommander)
  }

  // MARK: - RequiredDocumentsReceiver

  func addNewData(_ result: Result<[UIRequiredDocument], NSError>) {
    switch result {
    case .failure(let error):
      self.view.show(error: error, uiConfig: nil)
    case .success(let requiredDocuments):
      let requiredDocumentsViewModel = requiredDocuments.compactMap { requiredDocument -> RequiredDocumentViewModel in
        switch requiredDocument.requiredDocument {
        case .ID:
          return RequiredDocumentViewModel(
            uiRequiredDocument:requiredDocument,
            enabledIcon: UIImage.imageFromPodBundle("doc_id_enabled.png")!,
            disabledIcon: UIImage.imageFromPodBundle("doc_id_disabled")!,
            docName: requiredDocument.requiredDocument.description()
          )
        case .bankStatement:
          return RequiredDocumentViewModel(
            uiRequiredDocument:requiredDocument,
            enabledIcon: UIImage.imageFromPodBundle("doc_bank_statement_enabled.png")!,
            disabledIcon: UIImage.imageFromPodBundle("doc_bank_statement_disabled.png")!,
            docName: requiredDocument.requiredDocument.description()
          )
        case .proofOfAddress:
          return RequiredDocumentViewModel(
            uiRequiredDocument:requiredDocument,
            enabledIcon: UIImage.imageFromPodBundle("doc_address_proof_enabled.png")!,
            disabledIcon: UIImage.imageFromPodBundle("doc_address_proof_disabled.png")!,
            docName: requiredDocument.requiredDocument.description()
          )
        case .other:
          return RequiredDocumentViewModel(
            uiRequiredDocument:requiredDocument,
            enabledIcon: UIImage.imageFromPodBundle("doc_other_enabled.png")!,
            disabledIcon: UIImage.imageFromPodBundle("doc_other_disabled.png")!,
            docName: requiredDocument.requiredDocument.description()
          )
        }
      }
      self.viewModel.requiredDocuments.next(requiredDocumentsViewModel)
    }
  }

  // MARK: - Private methods

  fileprivate func uploadDocuments() {
    view.showUploadingState()
    let delayTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: delayTime) { [weak self] in
      self?.interactor.upload { [weak self] result in
        guard let wself = self else {
          return
        }
        switch result {
        case .failure(let error):
          wself.view.show(error: error, uiConfig: nil)
        case .success:
          wself.view.showMessage("doc-uploader.documents-sent".podLocalized(), uiConfig: nil)
          wself.router.back(true)
        }
      }
    }
  }

}

extension DocUploaderPresenter: FileCommanderDelegate {
  func fileDeleted(_ file:File) {
    self.interactor.loadRequiredDocuments()
  }
}
