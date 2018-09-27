//
//  LoanApplication.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/01/16.
//  Copyright © 2018 Shift. All rights reserved.
//

import Foundation
import Bond

// MARK: - Loan

open class LoanPurpose {
  open var loanPurposeId: Int
  open var description: String
  public init(loanPurposeId:Int, description:String) {
    self.loanPurposeId = loanPurposeId
    self.description = description
  }
}

@objc open class AppLoanData: NSObject {
  open var purposeId: Observable<Int?> = Observable(nil)
  open var amount: Amount?
  open var category: LoanCategory?
  override public init() {
    self.purposeId.next(nil)
    self.amount = Amount()
    self.category = .consumer
  }
  open func complete() -> Bool {
    guard let _ = purposeId.value, let _ = amount, let _ = category else {
      return false
    }
    return true
  }
  open func clearLoanData() {
    self.purposeId.next(nil)
    self.amount = Amount()
    self.category = .consumer
  }
  @objc func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = AppLoanData()
    retVal.purposeId.next(self.purposeId.value)
    retVal.amount = self.amount?.copy() as? Amount
    retVal.category = self.category
    return retVal
  }
}

@objc open class MerchantData: NSObject {
  open var projectKey: String?
  open var partnerKey: String?
  open var merchantKey: String?
  open var storeKey: String?
  override public init() {
    self.projectKey = nil
    self.partnerKey = nil
    self.merchantKey = nil
    self.storeKey = nil
  }
  open func complete() -> Bool {
    guard let _ = projectKey, let _ = partnerKey, let _ = merchantKey, let _ = storeKey else {
      return false
    }
    return true
  }
}

// MARK: - Application

public enum AppStatus {
  case unknown
  case approved
  case denied(reason:String)
}

// MARK: - Link File

open class LinkFile: File {
  
  var fileNumber: Int = 0
  var documentType: Int
  
  struct propertyNames {
    static let DOC_TYPE = "documentType"
    static let FILE_NUMBER = "fileNumber"
  }
  
  open func fileAsDict(requiredDocument:RequiredDocument) -> [String:AnyObject] {
    var fileData = self.fileAsDict()
    fileData[propertyNames.DOC_TYPE] = requiredDocument.id() as AnyObject
    fileData[propertyNames.FILE_NUMBER] = self.fileNumber as AnyObject
    return fileData
  }
  
  init(documentType:Int, fileNumber:Int? = nil, type: FileType, name: String? = nil, path: String? = nil) {
    self.documentType = documentType
    if fileNumber != nil {
      self.fileNumber = fileNumber!
    }
    super.init(type: type, name: name, path: path)
  }
  
  init(path:String) throws {
    guard let dict = NSDictionary(contentsOfFile: path) else {
      throw NSError.init(domain: "", code: 0, userInfo: nil)
    }
    guard let
      documentType = dict[propertyNames.DOC_TYPE] as? Int,
      let fileNumber = dict[propertyNames.FILE_NUMBER] as? Int else {
        throw NSError.init(domain: "", code: 0, userInfo: nil)
    }
    guard let rawType = dict[basicPropertyNames.FILE_TYPE] as? Int else {
      throw NSError.init(domain: "", code: 0, userInfo: nil)
    }
    guard let type = FileType(rawValue: rawType) else {
      throw NSError.init(domain: "", code: 0, userInfo: nil)
    }
    let name:String? = (dict[basicPropertyNames.FILE_NAME] as? String) ?? nil
    self.documentType = documentType
    self.fileNumber = fileNumber
    super.init(type: type, name: name, path: path)
  }
  
}

