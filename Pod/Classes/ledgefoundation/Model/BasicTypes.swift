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

let currencySymbols: [String: String] = [
  "USD": "$",
  "EUR": "€",
  "BTC": "BTC",
  "ETH": "ETH",
  "BTH": "BTH"
]

@objc open class Amount: NSObject {
  open var amount: Observable<Double?> = Observable(0)
  open var currency: Observable<String?> = Observable("USD")
  open var currencySymbol: String? {
    if let currency = currency.value {
      return currencySymbols[currency]
    }
    return nil
  }
  open var text: String {
    return text(withFormat: ".2")
  }
  open var longText: String {
    return text(withFormat: ".5")
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

  @objc func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = Amount(value: self.amount.value, currency: self.currency.value)
    return retVal
  }

  private func text(withFormat format: String) -> String {
    var currency = ""
    var value: Double = 0
    if let currencySymbol = self.currencySymbol {
      currency = currencySymbol
    }
    if let amount = self.amount.value {
      value = amount
    }
    return "\(currency) \(value.format(format))"
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

public struct Country : Equatable {
  public var isoCode: String
  public var name: String
}

public func ==(lhs: Country, rhs: Country) -> Bool {
  return lhs.isoCode == rhs.isoCode
}

public struct State {
  public var isoCode: String
  public var name: String
}

@objc public enum LoanCategory: NSInteger {
  case consumer     = 1
  case consumerPos  = 2
}
