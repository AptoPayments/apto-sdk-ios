//
//  FileCommander.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/04/16.
//
//

import Foundation

class FileCommander {
  
  fileprivate let fileManager = FileManager.default
  
  func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
  }
  
  func loadFileList(_ folderName: String, fileExtension: String? = nil) -> [String]? {
    var contents: [String] = []
    do {
      let folderPath = baseFolder(folderName)
      contents = try fileManager.contentsOfDirectory(atPath: folderPath)
    }
    catch _ {
      return nil
    }
    if fileExtension != nil {
      contents = contents.filter { $0.hasSuffix(fileExtension!) }
    }
    return contents
  }
  
  func writeDict(_ dict:[String: AnyObject], folderName: String, fileName:String) {
    var isDir : ObjCBool = false
    if self.fileManager.fileExists(atPath: baseFolder(folderName), isDirectory:&isDir) == false {
      do {
        try self.fileManager.createDirectory(atPath: baseFolder(folderName), withIntermediateDirectories: true, attributes: nil)
      }
      catch _ {
        return
      }
    }
    // TODO: Investigate how to write the dictionary on disk.
    //let filePath = (baseFolder(folderName) as NSString).appendingPathComponent(fileName)
    //let nsDict = NSDictionary(dict)
    //nsDict.write(to: filePath, atomically: true)
  }
  
  func readDict(_ atPath:String) -> NSDictionary? {
    guard let dict = NSDictionary(contentsOfFile: atPath) else {
      return nil
    }
    return dict
  }
  
  func deleteFile(_ folderName: String, fileName:String) -> Void {
    let filePath = (folderName as NSString).appendingPathComponent(fileName)
    deleteFile(filePath)
  }
  
  func deleteFile(_ atPath:String) -> Void {
    if (self.fileManager.isDeletableFile(atPath: atPath)) {
      do {
        try self.fileManager.removeItem(atPath: atPath)
      }
      catch _ {}
    }
  }
  
  // MARK: - Private methods
  
  fileprivate func baseFolder(_ folderName: String) -> String {
    return self.getDocumentsDirectory().appendingPathComponent(folderName)
  }
  
  
}
