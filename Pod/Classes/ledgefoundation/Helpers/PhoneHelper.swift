//
//  PhoneHelper.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 09/02/16.
//
//

import Foundation
import libPhoneNumber_iOS

public class PhoneHelper {
  
  let defaultRegionCode = "US"

  static var sharedInstance: PhoneHelper?
  public static func sharedHelper() -> PhoneHelper {
    guard let sharedInstance = PhoneHelper.sharedInstance else {
      PhoneHelper.sharedInstance = PhoneHelper()
      return PhoneHelper.sharedInstance!
    }
    return sharedInstance
  }
  
  let phoneValidator: NBPhoneNumberUtil! = NBPhoneNumberUtil.sharedInstance()

  func examplePhoneWith(countryCode:Int? = nil) -> String {
    do {
      let parsedPhone = try phoneValidator?.getExampleNumber(defaultRegionCode)
      let formattedPhone = try phoneValidator.format(parsedPhone, numberFormat: .NATIONAL)
      return formattedPhone
    } catch _ {
      return ""
    }
  }
  
  public func validatePhoneWith(countryCode:Int? = nil, nationalNumber:String?) -> Bool {
    guard let nationalNumber = nationalNumber, let phoneValidator = phoneValidator else {
      return false
    }
    do {
      let parsedPhone = try phoneValidator.parse(nationalNumber, defaultRegion: defaultRegionCode)
      return phoneValidator.isValidNumber(parsedPhone)
    } catch _ {
      return false
    }
  }
  
  public func formatPhoneWith(countryCode:Int? = nil, nationalNumber:String?) -> String {
    guard let nationalNumber = nationalNumber, let phoneValidator = phoneValidator else {
      return ""
    }
    do {
      let parsedPhone = try phoneValidator.parse(nationalNumber, defaultRegion: defaultRegionCode)
      let formattedPhone = try phoneValidator.format(parsedPhone, numberFormat: .NATIONAL)
      return formattedPhone
    } catch _ {
      return nationalNumber
    }
  }
  
  public func parsePhoneWith(countryCode:Int? = nil, nationalNumber:String?) -> PhoneNumber? {
    guard let nationalNumber = nationalNumber else {
      return nil
    }
    do {
      if let parsedPhone = try phoneValidator?.parse(nationalNumber, defaultRegion: defaultRegionCode), let nationalNumber = parsedPhone.nationalNumber {
        let phoneNumber = PhoneNumber(
          countryCode:parsedPhone.countryCode.intValue,
          phoneNumber:"\(nationalNumber)")
        return phoneNumber
      }
      return nil
    } catch _ {
      return nil
    }
  }
  
}
