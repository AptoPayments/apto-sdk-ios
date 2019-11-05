//
//  BasicTypes.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/01/16.
//  Copyright © 2018 Shift. All rights reserved.
//

import Foundation
import Bond

// MARK: - Basic Data Types
private var customCurrencySymbols = ["MXN": "MXN"]
private var currencySymbols: [String: String] = [:]

@objc open class Amount: NSObject, Codable {
  open var amount: Observable<Double?> = Observable(0)
  open var currency: Observable<String?> = Observable("USD")
  open var currencySymbol: String? {
    if let currency = currency.value {
      if let symbol = currencySymbols[currency] {
        return symbol
      }
      else if let symbol = customCurrencySymbols[currency] {
        currencySymbols[currency] = addSymbolSpaces(symbol: symbol)
      }
      else {
        if let identifier = Locale.availableIdentifiers.first(where: {
          Locale(identifier: $0).currencyCode == currency
        }) {
          currencySymbols[currency] = Locale(identifier: identifier).currencySymbol
        }
        else {
          currencySymbols[currency] = addSymbolSpaces(symbol: currency)
        }
      }
      return currencySymbols[currency]
    }
    return nil
  }
  open var text: String {
    if let value = self.amount.value {
      return textRepresentation(amount: value)
    }
    return textRepresentation(amount: 0)
  }
  open var absText: String {
    if let value = self.amount.value {
      return textRepresentation(amount: abs(value))
    }
    return textRepresentation(amount: 0)
  }

  fileprivate func textRepresentation(amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 10
    formatter.numberStyle = .currency
    if let currencySymbol = self.currencySymbol {
      formatter.currencySymbol = currencySymbol
    }
    let value = round(amount, toSignificantDecimalFigures: 2)
    return formatter.string(from: NSNumber(value: value))?.trimmingCharacters(in: CharacterSet.whitespaces) ?? "-"
      .replacingOccurrences(of: " ", with: "\u{A0}")
  }

  fileprivate func addSymbolSpaces(symbol: String) -> String {
    if #available(iOS 13, *) {
      return" \(symbol)"
    }
    else {
      // We need the whitespaces to cheat NumberFormatter and have a whitespace between the value and symbol
      return " \(symbol) "
    }
  }

  open var exchangeText: String {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 10
    formatter.minimumFractionDigits = 2
    formatter.numberStyle = .decimal
    var value: Double = 0
    if let amount = self.amount.value {
      value = abs(round(amount, toSignificantDecimalFigures: 2))
    }
    let formattedValue = formatter.string(from: NSNumber(value: value)) ?? "0.00"
    guard var currencySymbol = self.currencySymbol else {
      return formattedValue
    }
    currencySymbol = currencySymbol.trimmingCharacters(in: CharacterSet.whitespaces)
    return "\(formattedValue) \(currencySymbol)".trimmingCharacters(in: CharacterSet.whitespaces)
  }

  override public init() {
    self.amount.send(nil)
    self.currency.send(nil)
  }

  public init(value: Double?, currency: String?) {
    self.amount.send(value)
    self.currency.send(currency)
  }

  open func complete() -> Bool {
    return self.amount.value != nil && self.currency.value != nil
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

  // MARK: - Codable
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let amount = try container.decodeIfPresent(Double.self, forKey: .amount)
    let currency = try container.decodeIfPresent(String.self, forKey: .currency)
    self.amount.send(amount)
    self.currency.send(currency)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    if let amount = amount.value {
      try container.encode(amount, forKey: .amount)
    }
    if let currency = currency.value {
      try container.encode(currency, forKey: .currency)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case amount
    case currency
  }
}

open class HousingType {
  open var housingTypeId: Int
  open var description: String?

  public init(housingTypeId: Int, description: String? = nil) {
    self.housingTypeId = housingTypeId
    self.description = description
  }
}

extension HousingType: Equatable { }

public func ==(lhs: HousingType, rhs: HousingType) -> Bool { // swiftlint:disable:this operator_whitespace
  return lhs.housingTypeId == rhs.housingTypeId
}

open class IncomeType {
  open var incomeTypeId: Int
  open var description: String?

  public init(incomeTypeId: Int, description: String? = nil) {
    self.incomeTypeId = incomeTypeId
    self.description = description
  }
}

extension IncomeType: Equatable { }

public func ==(lhs: IncomeType, rhs: IncomeType) -> Bool { // swiftlint:disable:this operator_whitespace
  return lhs.incomeTypeId == rhs.incomeTypeId
}

open class SalaryFrequency {
  open var salaryFrequencyId: Int
  open var description: String?

  public init(salaryFrequencyId: Int, description: String? = nil) {
    self.salaryFrequencyId = salaryFrequencyId
    self.description = description
  }
}

extension SalaryFrequency: Equatable { }

public func ==(lhs: SalaryFrequency, rhs: SalaryFrequency) -> Bool { // swiftlint:disable:this operator_whitespace
  return lhs.salaryFrequencyId == rhs.salaryFrequencyId
}

open class TimeAtAddressOption {
  open var timeAtAddressId: Int
  open var description: String?

  public init(timeAtAddressId: Int, description: String? = nil) {
    self.timeAtAddressId = timeAtAddressId
    self.description = description
  }
}

extension TimeAtAddressOption: Equatable { }

 // swiftlint:disable:next operator_whitespace
public func ==(lhs: TimeAtAddressOption, rhs: TimeAtAddressOption) -> Bool {
  return lhs.timeAtAddressId == rhs.timeAtAddressId
}

open class CreditScoreOption {
  open var creditScoreId: Int
  open var description: String?

  public init(creditScoreId: Int, description: String? = nil) {
    self.creditScoreId = creditScoreId
    self.description = description
  }
}

extension CreditScoreOption: Equatable { }

public func ==(lhs: CreditScoreOption, rhs: CreditScoreOption) -> Bool { // swiftlint:disable:this operator_whitespace
  return lhs.creditScoreId == rhs.creditScoreId
}

public struct Country: Hashable, Codable {
  public var isoCode: String
  public var name: String

  public var flag: String {
    let lowercasedCode = isoCode.lowercased()
    guard lowercasedCode.count == 2 else { return "" }

    let indicatorSymbols = lowercasedCode.unicodeScalars.map { regionalIndicatorSymbol(for: $0) }
    return String(indicatorSymbols.map { Character($0) })
  }

  public static var defaultCountry = Country(isoCode: "US")

  private func regionalIndicatorSymbol(for scalar: Unicode.Scalar) -> Unicode.Scalar {
    // 0x1F1E6 marks the start of the Regional Indicator Symbol range and corresponds to 'A'
    // 0x61 marks the start of the lowercase ASCII alphabet: 'a'
    return Unicode.Scalar(scalar.value + (0x1F1E6 - 0x61))! // swiftlint:disable:this force_unwrapping
  }
}

public func ==(lhs: Country, rhs: Country) -> Bool { // swiftlint:disable:this operator_whitespace
  return lhs.isoCode == rhs.isoCode
}

extension Country {
  init(isoCode: String) {
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
  case consumer = 1
  case consumerPos = 2
}
