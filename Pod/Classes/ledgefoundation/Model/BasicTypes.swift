//
//  BasicTypes.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/01/16.
//  Copyright © 2018 Shift. All rights reserved.
//

import Foundation
import Bond

// MARK: - Basic Data Types

var currencySymbols: [String: String] = [
  // We need the whitespaces to cheat NumberFormatter and have a whitespace between the value and symbol
  "BTC": " BTC ",
  "BTH": " BTH ",
  "ETH": " ETH ",
  "ETC": " ETC ",
  "LTC": " LTC ",
  "ZRX": " ZRX "
]

@objc open class Amount: NSObject {
  open var amount: Observable<Double?> = Observable(0)
  open var currency: Observable<String?> = Observable("USD")
  open var currencySymbol: String? {
    if let currency = currency.value {
      if let symbol = currencySymbols[currency] {
        return symbol
      }
      else {
        guard let identifier = Locale.availableIdentifiers.first(where: { Locale(identifier: $0).currencyCode == currency }) else {
          return nil
        }
        currencySymbols[currency] = Locale(identifier: identifier).currencySymbol
        return currencySymbols[currency]
      }
    }
    return nil
  }
  open var text: String {
    return text(withDecimalPlaces: 2)
  }
  open var longText: String {
    return text(withDecimalPlaces: 5)
  }

  override public init() {
    self.amount.next(nil)
    self.currency.next(nil)
  }

  public init(value: Double?, currency: String?) {
    self.amount.next(value)
    self.currency.next(currency)
  }

  open func complete() -> Bool {
    guard let _ = self.amount.value, let _ = self.currency.value else {
      return false
    }
    return true
  }

  open func sameCurrencyThan(amount: Amount?) -> Bool {
    if let otherAmount = amount {
      return otherAmount.currency.value == currency.value
    }
    return false
  }

  @objc func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = Amount(value: self.amount.value, currency: self.currency.value)
    return retVal
  }

  private func text(withDecimalPlaces decimalPlaces: Int) -> String {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = decimalPlaces
    formatter.numberStyle = .currency
    if let currencySymbol = self.currencySymbol {
      formatter.currencySymbol = currencySymbol
    }
    var value: Double = 0
    if let amount = self.amount.value {
      value = amount
    }
    return formatter.string(from: NSNumber(value: value))?.trimmingCharacters(in: CharacterSet.whitespaces) ?? "-"
  }
}

open class HousingType {
  open var housingTypeId: Int
  open var description: String?
  public init(housingTypeId:Int, description:String? = nil) {
    self.housingTypeId = housingTypeId
    self.description = description
  }
}

extension HousingType: Equatable { }

public func ==(lhs: HousingType, rhs: HousingType) -> Bool {
  return lhs.housingTypeId == rhs.housingTypeId
}

open class IncomeType {
  open var incomeTypeId: Int
  open var description: String?
  public init(incomeTypeId:Int, description:String? = nil) {
    self.incomeTypeId = incomeTypeId
    self.description = description
  }
}

extension IncomeType: Equatable { }

public func ==(lhs: IncomeType, rhs: IncomeType) -> Bool {
  return lhs.incomeTypeId == rhs.incomeTypeId
}

open class SalaryFrequency {
  open var salaryFrequencyId: Int
  open var description: String?
  public init(salaryFrequencyId:Int, description:String? = nil) {
    self.salaryFrequencyId = salaryFrequencyId
    self.description = description
  }
}

extension SalaryFrequency: Equatable { }

public func ==(lhs: SalaryFrequency, rhs: SalaryFrequency) -> Bool {
  return lhs.salaryFrequencyId == rhs.salaryFrequencyId
}

open class TimeAtAddressOption {
  open var timeAtAddressId: Int
  open var description: String?
  public init(timeAtAddressId:Int, description:String? = nil) {
    self.timeAtAddressId = timeAtAddressId
    self.description = description
  }
}

extension TimeAtAddressOption: Equatable { }

public func ==(lhs: TimeAtAddressOption, rhs: TimeAtAddressOption) -> Bool {
  return lhs.timeAtAddressId == rhs.timeAtAddressId
}

open class CreditScoreOption {
  open var creditScoreId: Int
  open var description: String?
  public init(creditScoreId:Int, description:String? = nil) {
    self.creditScoreId = creditScoreId
    self.description = description
  }
}

extension CreditScoreOption: Equatable { }

public func ==(lhs: CreditScoreOption, rhs: CreditScoreOption) -> Bool {
  return lhs.creditScoreId == rhs.creditScoreId
}

public struct Country : Hashable {
  public var isoCode: String
  public var name: String

  public var flag: String {
    let lowercasedCode = isoCode.lowercased()
    guard lowercasedCode.count == 2 else { return "" }

    let indicatorSymbols = lowercasedCode.unicodeScalars.map{ regionalIndicatorSymbol(for: $0) }
    return String(indicatorSymbols.map{ Character($0) })
  }

  public static var defaultCountry = Country(isoCode: "US")

  private func regionalIndicatorSymbol(for scalar: Unicode.Scalar) -> Unicode.Scalar {
    // 0x1F1E6 marks the start of the Regional Indicator Symbol range and corresponds to 'A'
    // 0x61 marks the start of the lowercase ASCII alphabet: 'a'
    return Unicode.Scalar(scalar.value + (0x1F1E6 - 0x61))! // swiftlint:disable:this force_unwrapping
  }
}

public func ==(lhs: Country, rhs: Country) -> Bool {
  return lhs.isoCode == rhs.isoCode
}

public extension Country {
  public init(isoCode: String) {
    let currentLocale = NSLocale.current as NSLocale
    guard let name = currentLocale.localizedString(forCountryCode: isoCode) else {
      fatalError("Wrong country code: \(isoCode)")
    }
    self.init(isoCode: isoCode, name: name)
  }
}

public struct State {
  public var isoCode: String
  public var name: String
}

@objc public enum LoanCategory: NSInteger {
  case consumer     = 1
  case consumerPos  = 2
}
