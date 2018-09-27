//
//  DocUploaderInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 24/03/16.
//
//

import Foundation
import Bond

protocol LinkDocUploaderDataReceiver {
  func addNewData(_ result: Result<[UIRequiredDocument], NSError>)
}

class UIRequiredDocument {
  let requiredDocument: RequiredDocument
  var files: Observable<[File]?> = Observable(nil)
  init (requiredDocument:RequiredDocument) {
    self.requiredDocument = requiredDocument
  }
}

class LinkDocUploaderInteractor: LinkDocUploaderInteractorProtocol {

  let session: ShiftSession
  let application: LoanApplication
  let dataReceiver: LinkDocUploaderDataReceiver
  let linkFileStorage = LinkFileStorage()

  init(session: ShiftSession, dataReceiver: LinkDocUploaderDataReceiver, application: LoanApplication) {
    self.session = session
    self.application = application
    self.dataReceiver = dataReceiver
  }

  func loadRequiredDocuments() {
//    guard let requiredActions = self.application.requiredActions else {
//      self.dataReceiver.addNewData(.failure(ServiceError(code:.internalIncosistencyError)))
//      return
//    }
//    var valid = false
//    for requiredAction in requiredActions {
//      switch requiredAction {
//      case .uploadDoc(let requiredDocuments):
//        let uiRequiredDocuments = requiredDocuments.flatMap { requiredDocument -> UIRequiredDocument in
//          let files = self.linkFileStorage.getRequiredDocumentFiles(self.application, requiredDocument: requiredDocument)
//          let retVal = UIRequiredDocument.init(requiredDocument: requiredDocument)
//          retVal.files.next(files)
//          return retVal
//        }
//        self.dataReceiver.addNewData(.success(uiRequiredDocuments))
//        valid = true
//      default:
//        break
//      }
//    }
//    if valid == false {
//      self.dataReceiver.addNewData(.failure(ServiceError(code:.internalIncosistencyError)))
//    }
  }

  func store(fileForRequiredDocument requiredDocument:UIRequiredDocument, file:LinkFile) {
    self.linkFileStorage.store(linkFile: file, application: self.application, requiredDocument: requiredDocument.requiredDocument)
  }

  func delete(fileForRequiredDocument requiredDocument:UIRequiredDocument, file: LinkFile) {
    self.linkFileStorage.delete(linkFile: file, application: self.application, requiredDocument: requiredDocument.requiredDocument)
  }

  func upload(callback:Result<LoanApplication,NSError>.Callback) {
    // TODO: Implement
  }

  func folderFor(requiredDocument:RequiredDocument) -> String {
    return self.linkFileStorage.folderFor(self.application, requiredDocument: requiredDocument)
  }

}
