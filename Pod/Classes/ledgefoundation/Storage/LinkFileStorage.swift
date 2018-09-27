//
//  LinkFileStorage.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 03/04/16.
//
//

import Foundation

protocol LinkFileStorageProtocol {
  func getRequiredDocumentFiles(_ application: LoanApplication, requiredDocument: RequiredDocument) -> [LinkFile]?
  func store(linkFile: LinkFile, application: LoanApplication, requiredDocument: RequiredDocument)
  func delete(linkFile: LinkFile, application: LoanApplication, requiredDocument: RequiredDocument)
  func delete(linkFile: LinkFile)
  func folderFor(_ application: LoanApplication, requiredDocument: RequiredDocument) -> String
}

class LinkFileStorage: LinkFileStorageProtocol {
  func getRequiredDocumentFiles(_ application: LoanApplication, requiredDocument: RequiredDocument) -> [LinkFile]? {
    guard let filePaths = fileCommander.loadFileList(folderFor(application, requiredDocument: requiredDocument),
                                                     fileExtension: "dat") else {
      return nil
    }
    if !filePaths.isEmpty {
      let files = filePaths.compactMap { filePath -> LinkFile? in
        let folderPath = self.folderFor(application, requiredDocument: requiredDocument)
        let path = fileCommander.getDocumentsDirectory().appendingPathComponent(folderPath) as NSString
        return self.readFile(path.appendingPathComponent(filePath))
      }
      return files
    }
    return nil
  }

  func store(linkFile: LinkFile, application: LoanApplication, requiredDocument: RequiredDocument) {
    if linkFile.fileNumber == 0 {
      if let existingFiles = getRequiredDocumentFiles(application, requiredDocument: requiredDocument) {
        linkFile.fileNumber = existingFiles.count + 1
      }
      else {
        linkFile.fileNumber = 1
      }
    }
    let fileData = linkFile.fileAsDict(requiredDocument: requiredDocument)
    let folderName = folderFor(application, requiredDocument: requiredDocument)
    let fileName = self.fileName(linkFile)
    self.fileCommander.writeDict(fileData, folderName: folderName, fileName: fileName)
  }

  func delete(linkFile: LinkFile, application: LoanApplication, requiredDocument: RequiredDocument) {
    let folderName = self.folderFor(application, requiredDocument: requiredDocument)
    let fileName = self.fileName(linkFile)
    self.fileCommander.deleteFile(folderName, fileName: fileName)
  }

  func delete(linkFile: LinkFile) {
    guard let path = linkFile.path else {
      return
    }
    self.fileCommander.deleteFile(path)
  }

  func folderFor(_ application: LoanApplication, requiredDocument: RequiredDocument) -> String {
    return application.id
  }

  // MARK: - Private methods

  private let fileCommander = FileCommander()

  private func fileName(_ file: LinkFile) -> String {
    return "\(file.fileNumber).dat"
  }

  private func readFile(_ atPath: String) -> LinkFile? {
    do {
      return try LinkFile(path: atPath)
    }
    catch _ {
      return nil
    }
  }
}
