//
//  BasicTypes.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/01/16.
//  Copyright © 2018 Shift. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

// MARK: - Data Points

@objc public enum DataPointType: Int {
  case personalName
  case phoneNumber
  case email
  case birthDate
  case idDocument
  case address
  case housing
  case incomeSource
  case income
  case creditScore
  case paydayLoan
  case memberOfArmedForces
  case timeAtAddress
  case financialAccount

  // swiftlint:disable cyclomatic_complexity
  static func from(typeName: String?) -> DataPointType? {
    switch typeName {
    case "email": return .email
    case "phone": return .phoneNumber
    case "name": return .personalName
    case "address": return .address
    case "birthdate": return .birthDate
    case "id_document": return .idDocument
    case "income_source": return .incomeSource
    case "housing": return .housing
    case "income": return .income
    case "credit_score": return .creditScore
    case "payday_loan": return .paydayLoan
    case "member_of_armed_forces": return .memberOfArmedForces
    case "time_at_address": return .timeAtAddress
    default: return nil
    }
  }
  // swiftlint:enable cyclomatic_complexity

  var description: String {
    switch self {
    case .personalName: return "name"
    case .phoneNumber: return "phone"
    case .email: return "email"
    case .address: return "address"
    case .birthDate: return "birthdate"
    case .idDocument: return "id_document"
    case .incomeSource: return "income_source"
    case .housing: return "housing"
    case .income: return "income"
    case .creditScore: return "credit_score"
    case .paydayLoan: return "payday_loan"
    case .memberOfArmedForces: return "member_of_armed_forces"
    case .timeAtAddress: return "time_at_address"
    case .financialAccount: return "financial_account"
    }
  }
}

public protocol CountryRestrictedDataPoint {
  var country: Observable<Country?> { get }
}

@objc open class DataPoint: NSObject {
  public let type: DataPointType
  open var verification: Verification?
  open var verified: Bool?
  open var notSpecified: Bool?

  public init(type: DataPointType, verified: Bool? = false, notSpecified: Bool? = false) {
    self.type = type
    self.verified = verified
    self.notSpecified = notSpecified
    super.init()
  }

  func invalidateVerification() {
    self.verification = nil
    self.verified = false
  }

  open func complete() -> Bool {
    return false
  }

  @objc func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = DataPoint(type: self.type, verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc open class PersonalName: DataPoint {
  private let disposeBag = DisposeBag()
  open var firstName: Observable<String?> = Observable(nil)
  open var lastName: Observable<String?> = Observable(nil)

  convenience public init(firstName: String?, lastName: String?, verified: Bool? = false) {
    self.init(type: .personalName, verified: verified)
    self.firstName.send(firstName)
    self.lastName.send(lastName)
    self.firstName.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.lastName.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }

  @objc convenience public init(firstName: String?, lastName: String?, verified: Bool) {
    self.init(firstName: firstName, lastName: lastName, verified: verified as Bool?)
  }

  convenience public init() {
    self.init(firstName: nil, lastName: nil, verified: false)
  }

  override open func complete() -> Bool {
    return firstName.value != nil && lastName.value != nil
  }

  open func fullName() -> String? {
    if let firstNameStr = firstName.value, let lastNameStr = lastName.value {
      return firstNameStr + " " + lastNameStr
    }
    else if let firstNameStr = firstName.value {
      return firstNameStr
    }
    else if let lastNameStr = lastName.value {
      return lastNameStr
    }
    return nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = PersonalName(firstName: self.firstName.value,
                              lastName: self.lastName.value,
                              verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc open class PhoneNumber: DataPoint, CountryRestrictedDataPoint, Codable {
  private let disposeBag = DisposeBag()
  open var countryCode: Observable<Int?> = Observable(nil)
  open var phoneNumber: Observable<String?> = Observable(nil)
  public let country: Observable<Country?> = Observable(nil)

  public init(countryCode: Int?, phoneNumber: String?, verified: Bool? = false) {
    self.countryCode.value = countryCode
    self.phoneNumber.value = phoneNumber
    super.init(type: .phoneNumber, verified: verified)
    setUpObservers()
    self.verified = verified
  }

  @objc convenience public init(countryCode: Int, phoneNumber: String?, verified: Bool) {
    self.init(countryCode: countryCode, phoneNumber: phoneNumber, verified: verified as Bool?)
  }

  convenience public init() {
    self.init(countryCode: nil, phoneNumber: nil, verified: false)
  }

  override open func complete() -> Bool {
    return countryCode.value != nil && phoneNumber.value != nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = PhoneNumber(countryCode: self.countryCode.value,
                             phoneNumber: self.phoneNumber.value,
                             verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }

  // MARK: - Codable
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.countryCode.value = try container.decodeIfPresent(Int.self, forKey: .countryCode)
    self.phoneNumber.value = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
    let verified = try container.decode(Bool.self, forKey: .verified)
    super.init(type: .phoneNumber, verified: verified)
    setUpObservers()
    self.verified = verified
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    if let countryCode = self.countryCode.value {
      try container.encode(countryCode, forKey: .countryCode)
    }
    if let phoneNumber = self.phoneNumber.value {
      try container.encode(phoneNumber, forKey: .phoneNumber)
    }
    try container.encode(verified ?? false, forKey: .verified)
  }

  private enum CodingKeys: String, CodingKey {
    case countryCode
    case phoneNumber
    case verified
  }

  // MARK: - Private methods

  private func setUpObservers() {
    self.countryCode.observeNext { [weak self] countryCode in
      self?.invalidateVerification()
      guard let countryCode = countryCode else { return }
      self?.country.send(Country(isoCode: PhoneHelper.sharedHelper().region(for: countryCode)))
    }.dispose(in: disposeBag)
    self.phoneNumber.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }
}

@objc open class Email: DataPoint {
  private let disposeBag = DisposeBag()
  open var email: Observable<String?> = Observable(nil)

  convenience public init(email: String?, verified: Bool?, notSpecified: Bool?) {
    self.init(type: .email, verified: verified, notSpecified: notSpecified)
    self.email.send(email)
    self.email.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.verified = verified
  }

  @objc convenience public init(email: String?, verified: Bool, notSpecified: Bool) {
    self.init(email: email, verified: verified as Bool?, notSpecified: notSpecified as Bool?)
  }

  convenience public init() {
    self.init(email: nil, verified: false, notSpecified: false)
  }

  override open func complete() -> Bool {
    if let notSpecified = self.notSpecified, notSpecified == true {
      return true
    }
    return self.email.value != nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = Email(email: self.email.value,
                       verified: self.verified,
                       notSpecified: self.notSpecified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc open class BirthDate: DataPoint {
  private let disposeBag = DisposeBag()
  open var date: Observable<Date?> = Observable(nil)

  convenience public init(date: Date?, verified: Bool? = false) {
    self.init(type: .birthDate, verified: verified)
    self.date.send(date)
    self.date.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.verified = verified
  }

  @objc convenience public init(date: Date?, verified: Bool) {
    self.init(date: date, verified: verified as Bool?)
  }

  convenience public init() {
    self.init(date: nil, verified: false)
  }

  override open func complete() -> Bool {
    return date.value != nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = BirthDate(date: self.date.value,
                           verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc public enum IdDocumentType: Int {
  case ssn
  case identityCard
  case passport
  case driversLicense

  public var description: String {
    switch self {
    case .ssn:
      return "ssn"
    case .identityCard:
      return "identity_card"
    case .passport:
      return "passport"
    case .driversLicense:
      return "drivers_license"
    }
  }

  public static func from(string documentType: String?) -> IdDocumentType? {
    switch documentType {
    case "ssn": return .ssn
    case "identity_card": return .identityCard
    case "passport": return .passport
    case "drivers_license": return .driversLicense
    default: return nil
    }
  }

  public var localizedDescription: String {
    switch self {
    case .ssn:
      return "birthday-collector.id-document.type.ssn".podLocalized()
    case .identityCard:
      return "birthday-collector.id-document.type.identity-card".podLocalized()
    case .passport:
      return "birthday-collector.id-document.type.passport".podLocalized()
    case .driversLicense:
      return "birthday-collector.id-document.type.drivers-license".podLocalized()
    }
  }
}

@objc open class IdDocument: DataPoint {
  private let disposeBag = DisposeBag()
  open var documentType: Observable<IdDocumentType?> = Observable(nil)
  open var value: Observable<String?> = Observable(nil)
  open var country: Observable<Country?> = Observable(nil)

  convenience public init(documentType: IdDocumentType?,
                          value: String?,
                          country: Country?,
                          verified: Bool? = false,
                          notSpecified: Bool? = false) {
    self.init(type: .idDocument, verified: verified, notSpecified: notSpecified)
    self.documentType.send(documentType)
    self.value.send(value)
    self.country.send(country)
    self.documentType.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.value.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.country.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }

  @objc convenience public init(documentType: IdDocumentType,
                                value: String?,
                                verified: Bool,
                                notSpecified: Bool) {
    self.init(documentType: documentType as IdDocumentType?,
              value: value,
              country: nil,
              verified: verified as Bool?,
              notSpecified: notSpecified as Bool?)
  }

  convenience public init() {
    self.init(documentType: nil, value: nil, country: nil)
  }

  override open func complete() -> Bool {
    if let notSpecified = self.notSpecified, notSpecified == true {
      return true
    }
    return value.value != nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = IdDocument(documentType: self.documentType.value,
                            value: self.value.value,
                            country: self.country.value,
                            verified: self.verified,
                            notSpecified: self.notSpecified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc open class Address: DataPoint, CountryRestrictedDataPoint, Codable {
  private let disposeBag = DisposeBag()
  open var address: Observable<String?> = Observable(nil)
  open var apUnit: Observable<String?> = Observable(nil)
  open var country: Observable<Country?> = Observable(nil)
  open var city: Observable<String?> = Observable(nil)
  open var region: Observable<String?> = Observable(nil)
  open var zip: Observable<String?> = Observable(nil)
  open var formattedAddress: String?

  public init(address: String?,
              apUnit: String?,
              country: Country?,
              city: String?,
              region: String?,
              zip: String?,
              verified: Bool? = false) {
    super.init(type: .address, verified: verified)
    self.address.send(address)
    self.apUnit.send(apUnit)
    self.country.send(country)
    self.city.send(city)
    self.region.send(region)
    self.zip.send(zip)
    self.address.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.apUnit.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.country.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.city.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.zip.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }

  @objc public convenience init(address: String?,
                                apUnit: String?,
                                countryCode: String?,
                                countryName: String?,
                                city: String?,
                                region: String?,
                                zip: String?,
                                verified: Bool) {
    let country: Country?
    if let countryCode = countryCode, let countryName = countryName {
      country = Country(isoCode: countryCode, name: countryName)
    }
    else {
      country = nil
    }
    self.init(address: address,
              apUnit: apUnit,
              country: country,
              city: city,
              region: region,
              zip: zip,
              verified: verified)
  }

  convenience public init() {
    self.init(address: nil, apUnit: nil, country: nil, city: nil, region: nil, zip: nil, verified: false)
  }

  override open func complete() -> Bool {
    return address.value != nil && city.value != nil && region.value != nil && zip.value != nil
  }

  open func addressDescription() -> String? {
    if self.country.value?.isoCode == "US" {
      var addressComponents: [String] = []
      if let address = self.address.value {
        addressComponents.append(address)
      }
      if let city = self.city.value {
        addressComponents.append(city)
      }
      if let stateCode = self.region.value {
        addressComponents.append(stateCode)
      }
      if let zip = self.zip.value {
        addressComponents.append(zip)
      }
      return addressComponents.joined(separator: ", ")
    }
    return nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = Address(address: self.address.value,
                         apUnit: self.apUnit.value,
                         country: self.country.value,
                         city: self.city.value,
                         region: self.region.value,
                         zip: self.zip.value,
                         verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }

  // MARK: - Codable
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let verified = try container.decodeIfPresent(Bool.self, forKey: .verified) ?? false
    super.init(type: .address, verified: verified)
    self.address.send(try container.decodeIfPresent(String.self, forKey: .address))
    self.apUnit.send(try container.decodeIfPresent(String.self, forKey: .apUnit))
    self.country.send(try container.decodeIfPresent(Country.self, forKey: .country))
    self.city.send(try container.decodeIfPresent(String.self, forKey: .city))
    self.region.send(try container.decodeIfPresent(String.self, forKey: .region))
    self.zip.send(try container.decodeIfPresent(String.self, forKey: .zip))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(address.value, forKey: .address)
    try container.encode(apUnit.value, forKey: .apUnit)
    try container.encode(country.value, forKey: .country)
    try container.encode(city.value, forKey: .city)
    try container.encode(region.value, forKey: .region)
    try container.encode(zip.value, forKey: .zip)
    try container.encode(verified, forKey: .verified)
  }

  private enum CodingKeys: String, CodingKey {
    case address
    case apUnit
    case country
    case city
    case region
    case zip
    case verified
  }
}

@objc open class Housing: DataPoint {
  private let disposeBag = DisposeBag()
  open var housingType: Observable<HousingType?> = Observable(nil)

  convenience public init(housingType: HousingType?, verified: Bool? = false) {
    self.init(type: .housing, verified: verified)
    self.housingType.send(housingType)
    self.housingType.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }

  convenience public init() {
    self.init(housingType: nil, verified: false)
  }

  override open func complete() -> Bool {
    return housingType.value != nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = Housing(housingType: self.housingType.value,
                         verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc open class IncomeSource: DataPoint {
  private let disposeBag = DisposeBag()
  open var salaryFrequency: Observable<SalaryFrequency?> = Observable(nil)
  open var incomeType: Observable<IncomeType?> = Observable(nil)

  convenience public init(salaryFrequency: SalaryFrequency?, incomeType: IncomeType?, verified: Bool? = false) {
    self.init(type: .incomeSource, verified: verified)
    self.salaryFrequency.send(salaryFrequency)
    self.incomeType.send(incomeType)
    self.salaryFrequency.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.incomeType.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }

  convenience public init() {
    self.init(salaryFrequency: nil, incomeType: nil, verified: false)
  }

  override open func complete() -> Bool {
    return salaryFrequency.value != nil && incomeType.value != nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = IncomeSource(salaryFrequency: self.salaryFrequency.value,
                              incomeType: self.incomeType.value,
                              verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc open class Income: DataPoint {
  private let disposeBag = DisposeBag()
  open var netMonthlyIncome: Observable<Int?> = Observable(nil)
  open var grossAnnualIncome: Observable<Int?> = Observable(nil)

  convenience public init(netMonthlyIncome: Int?, grossAnnualIncome: Int?, verified: Bool?) {
    self.init(type: .income, verified: verified)
    self.netMonthlyIncome.send(netMonthlyIncome)
    self.grossAnnualIncome.send(grossAnnualIncome)
    self.netMonthlyIncome.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    self.grossAnnualIncome.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }

  convenience public init() {
    self.init(netMonthlyIncome: nil, grossAnnualIncome: nil, verified: false)
  }

  override open func complete() -> Bool {
    return netMonthlyIncome.value != nil && grossAnnualIncome.value != nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = Income(netMonthlyIncome: self.netMonthlyIncome.value,
                        grossAnnualIncome: self.grossAnnualIncome.value,
                        verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc open class CreditScore: DataPoint {
  private let disposeBag = DisposeBag()
  open var creditRange: Observable<Int?> = Observable(nil)

  convenience public init(creditRange: Int?, verified: Bool? = false) {
    self.init(type: .creditScore, verified: verified)
    self.creditRange.send(creditRange)
    self.creditRange.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }

  convenience public init() {
    self.init(creditRange: nil, verified: false)
  }

  override open func complete() -> Bool {
    return creditRange.value != nil
  }

  static let creditScoreRangeScoreDescriptions = ["credit-score.excellent".podLocalized(),
                                                  "credit-score.good".podLocalized(),
                                                  "credit-score.fair".podLocalized(),
                                                  "credit-score.poor".podLocalized()]

  open func creditScoreRangeDescription() -> String? {
    guard let index = creditRange.value,
          index >= 0 && index < CreditScore.creditScoreRangeScoreDescriptions.count else {
      return ""
    }
    return CreditScore.creditScoreRangeScoreDescriptions[index]
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = CreditScore(creditRange: self.creditRange.value,
                             verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc open class PaydayLoan: DataPoint {
  private let disposeBag = DisposeBag()
  open var usedPaydayLoan: Observable<Bool?> = Observable(nil)

  convenience public init(usedPaydayLoan: Bool?, verified: Bool? = false) {
    self.init(type: .paydayLoan, verified: verified)
    self.usedPaydayLoan.send(usedPaydayLoan)
    self.usedPaydayLoan.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }

  convenience public init() {
    self.init(usedPaydayLoan: nil, verified: false)
  }

  override open func complete() -> Bool {
    return usedPaydayLoan.value != nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = PaydayLoan(usedPaydayLoan: self.usedPaydayLoan.value,
                            verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc open class MemberOfArmedForces: DataPoint {
  private let disposeBag = DisposeBag()
  open var memberOfArmedForces: Observable<Bool?> = Observable(nil)

  convenience public init(memberOfArmedForces: Bool?, verified: Bool? = false) {
    self.init(type: .memberOfArmedForces, verified: verified)
    self.memberOfArmedForces.send(memberOfArmedForces)
    self.memberOfArmedForces.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }

  convenience public init() {
    self.init(memberOfArmedForces: nil, verified: false)
  }

  override open func complete() -> Bool {
    return memberOfArmedForces.value != nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = MemberOfArmedForces(memberOfArmedForces: self.memberOfArmedForces.value,
                                     verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

@objc open class TimeAtAddress: DataPoint {
  private let disposeBag = DisposeBag()
  open var timeAtAddress: Observable<TimeAtAddressOption?> = Observable(nil)

  convenience public init(timeAtAddress: TimeAtAddressOption?, verified: Bool? = false) {
    self.init(type: .timeAtAddress, verified: verified)
    self.timeAtAddress.send(timeAtAddress)
    self.timeAtAddress.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
  }

  convenience public init() {
    self.init(timeAtAddress: nil, verified: false)
  }

  override open func complete() -> Bool {
    return timeAtAddress.value != nil
  }

  override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = TimeAtAddress(timeAtAddress: self.timeAtAddress.value,
                               verified: self.verified)
    if let verification = self.verification {
      retVal.verification = verification.copy() as? Verification
    }
    return retVal
  }
}

// MARK: - Datapoint equatable protocol

// swiftlint:disable operator_whitespace
func ==(lhs: Email, rhs: Email) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.email.value == rhs.email.value
}

func ==(lhs: PhoneNumber, rhs: PhoneNumber) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.countryCode.value == rhs.countryCode.value
    && lhs.phoneNumber.value == rhs.phoneNumber.value
}

func ==(lhs: PersonalName, rhs: PersonalName) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.firstName.value == rhs.firstName.value
    && lhs.lastName.value == rhs.lastName.value
}

func ==(lhs: DataPoint, rhs: DataPoint) -> Bool {
  return lhs.type == rhs.type
    && lhs.notSpecified == rhs.notSpecified
    && lhs.verified == rhs.verified
    && ((lhs.verification == nil && rhs.verification == nil)
        || (lhs.verification != nil && rhs.verification != nil && lhs.verification! == rhs.verification!))
  // swiftlint:disable:previous force_unwrapping
}

func ==(lhs: Address, rhs: Address) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.address.value == rhs.address.value
    && lhs.apUnit.value == rhs.apUnit.value
    && lhs.country.value == rhs.country.value
    && lhs.city.value == rhs.city.value
    && lhs.region.value == rhs.region.value
    && lhs.zip.value == rhs.zip.value
}

func ==(lhs: BirthDate, rhs: BirthDate) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.date.value == rhs.date.value
}

func ==(lhs: IdDocument, rhs: IdDocument) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.documentType.value == rhs.documentType.value
    && lhs.value.value == rhs.value.value
    && lhs.country.value == rhs.country.value
}

func ==(lhs: Housing, rhs: Housing) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.housingType.value == rhs.housingType.value
}

func ==(lhs: IncomeSource, rhs: IncomeSource) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.salaryFrequency.value == rhs.salaryFrequency.value
    && lhs.incomeType.value == rhs.incomeType.value
}

func ==(lhs: Income, rhs: Income) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.netMonthlyIncome.value == rhs.netMonthlyIncome.value
    && lhs.grossAnnualIncome.value == rhs.grossAnnualIncome.value
}

func ==(lhs: CreditScore, rhs: CreditScore) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.creditRange.value == rhs.creditRange.value
}

func ==(lhs: PaydayLoan, rhs: PaydayLoan) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.usedPaydayLoan.value == rhs.usedPaydayLoan.value
}

func ==(lhs: MemberOfArmedForces, rhs: MemberOfArmedForces) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.memberOfArmedForces.value == rhs.memberOfArmedForces.value
}

func ==(lhs: TimeAtAddress, rhs: TimeAtAddress) -> Bool {
  return lhs as DataPoint == rhs as DataPoint
    && lhs.timeAtAddress.value == rhs.timeAtAddress.value
}
// swiftlint:enable operator_whitespace
