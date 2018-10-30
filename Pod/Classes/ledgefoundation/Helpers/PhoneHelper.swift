//
//  PhoneHelper.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 09/02/16.
//
//

import Foundation
import PhoneNumberKit

public enum PhoneFormat: Int, Equatable {
  case national
  case international
  case nationalWithPrefix

  public var phoneNumberKitFormat: PhoneNumberFormat {
    switch self {
    case .national, .nationalWithPrefix:
      return .national
    case .international:
      return .international
    }
  }
}

public class PhoneHelper {
  let defaultRegionCode = "US"
  let defaultCountryCode = 1

  static var sharedInstance: PhoneHelper?
  public static func sharedHelper() -> PhoneHelper {
    guard let sharedInstance = PhoneHelper.sharedInstance else {
      PhoneHelper.sharedInstance = PhoneHelper()
      return PhoneHelper.sharedInstance!
    }
    return sharedInstance
  }

  let phoneValidator = PhoneNumberKit()

  public func validatePhoneWith(countryCode: Int? = nil, nationalNumber: String?) -> Bool {
    guard let nationalNumber = nationalNumber else {
      return false
    }
    let regionCode: String
    if let countryCode = countryCode {
      regionCode = region(for: countryCode)
    }
    else {
      regionCode = defaultRegionCode
    }
    return !phoneValidator.parse([nationalNumber],
                                 withRegion: regionCode,
                                 shouldReturnFailedEmptyNumbers: false).isEmpty
  }

  public func formatPhoneWith(countryCode: Int? = nil,
                              nationalNumber: String?,
                              numberFormat: PhoneFormat = .national) -> String {
    guard let nationalNumber = nationalNumber else {
      return ""
    }
    do {
      let countryCode = countryCode ?? defaultCountryCode
      let parsedPhone = try phoneValidator.parse(nationalNumber, withRegion: region(for: countryCode))
      let formattedPhone = phoneValidator.format(parsedPhone, toType: numberFormat.phoneNumberKitFormat)
      return numberFormat == .nationalWithPrefix ? "+\(countryCode) " + formattedPhone : formattedPhone
    }
    catch _ {
      return nationalNumber
    }
  }

  public func region(for countryCode: Int) -> String {
    guard let country = phoneValidator.mainCountry(forCode: UInt64(countryCode)) else {
      return defaultRegionCode
    }
    return country
  }

  public func countryCode(for region: String) -> Int {
    guard let code = phoneValidator.countryCode(for: region) else {
      return defaultCountryCode
    }
    return Int(code)
  }

  public func parsePhoneWith(countryCode: Int? = nil, nationalNumber: String?) -> PhoneNumber? {
    guard let nationalNumber = nationalNumber else {
      return nil
    }
    do {
      let countryCode = countryCode ?? defaultCountryCode
      let parsedPhone = try phoneValidator.parse(nationalNumber, withRegion: region(for: countryCode))
      let phoneNumber = PhoneNumber(countryCode: Int(parsedPhone.countryCode),
                                    phoneNumber: parsedPhone.adjustedNationalNumber())
      return phoneNumber
    }
    catch _ {
      return nil
    }
  }

  public func callURL(from phoneNumber: PhoneNumber?) -> URL? {
    guard let phoneNumber = phoneNumber,
          let countryCode = phoneNumber.countryCode.value,
          let number = phoneNumber.phoneNumber.value else {
      return nil
    }
    return URL(string: "tel://+\(countryCode)" + number)
  }
}
