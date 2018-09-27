//
//  FileCommanderInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 31/03/16.
//
//

import Foundation

protocol FileCommanderInteractorProtocol {
  func loadFileList(_ folderName: String, completion: ([File]?) -> Void)
  func write(file:File, folderName:String)
  func delete(file:File, folderName:String)
}

enum FileType: Int {
  case png = 0
  case pdf = 1
  case doc = 2
  case unknown = 3
}

open class File: NSObject {
  let type:FileType
  var name: String?
  var path: String?
  lazy var data: Data? = {
    guard let _ = self.path,
      let dict = NSDictionary(contentsOfFile: self.path!) else {
      return nil
    }
    guard let data = dict["data"] as? Data else {
      return nil
    }
    return Data(base64Encoded: data, options: NSData.Base64DecodingOptions())
  }()
  init(type: FileType, name: String? = nil, path: String?) {
    self.type = type
    self.name = name
    self.path = path
  }
  
}

extension File {

  struct basicPropertyNames {
    static let FILE_TYPE = "fileType"
    static let FILE_NAME = "fileName"
    static let FILE_DATA = "data"
  }

  public func fileAsDict() -> [String:AnyObject] {
    var fileData: [String:AnyObject] = [
      basicPropertyNames.FILE_TYPE:self.type.rawValue as AnyObject
      ]
    if self.data != nil {
      fileData[basicPropertyNames.FILE_DATA] = self.data!.base64EncodedData(options: NSData.Base64EncodingOptions()) as AnyObject
    }
    if self.name != nil {
      fileData[basicPropertyNames.FILE_NAME] = self.name! as AnyObject
    }
    return fileData
  }
  
  @objc convenience init(path:String) throws {
    guard let dict = NSDictionary(contentsOfFile: path) else {
      throw NSError.init(domain: "", code: 0, userInfo: nil)
    }
    guard let rawType = dict[basicPropertyNames.FILE_TYPE] as? Int else {
      throw NSError.init(domain: "", code: 0, userInfo: nil)
    }
    guard let type = FileType(rawValue: rawType) else {
      throw NSError.init(domain: "", code: 0, userInfo: nil)
    }
    let name:String? = (dict[basicPropertyNames.FILE_NAME] as? String) ?? nil
    self.init(type: type, name: name, path: path)
  }
  
}

class FileCommanderInteractor: FileCommanderInteractorProtocol {
  
  let fileCommander = FileCommander()
  
  func loadFileList(_ folderName: String, completion: ([File]?) -> Void) {
    guard let fileNames = self.fileCommander.loadFileList(folderName, fileExtension: "dat") else {
      completion(nil)
      return
    }
    let files = fileNames.compactMap { fileName -> File? in
      do {
        let path = (self.fileCommander.getDocumentsDirectory().appendingPathComponent(folderName) as NSString).appendingPathComponent(fileName)
        return try File.init(path: path)
      }
      catch _ { return nil }
    }
    completion(files)
  }
  
  func write(file:File, folderName:String) {
    let fileData = file.fileAsDict()
    guard let name = file.name else {
      return
    }
    self.fileCommander.writeDict(fileData, folderName: folderName, fileName: name)
  }
  
  func delete(file:File, folderName:String) {
    guard let path = file.path else {
      return
    }
    self.fileCommander.deleteFile(path)
  }
  
}
