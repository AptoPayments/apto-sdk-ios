//
//  BasicTypes.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/01/16.
//

import Bond
import Foundation
import ReactiveKit

// MARK: - Data Points

@objc public enum DataPointType: Int {
    case personalName
    case phoneNumber
    case email
    case birthDate
    case idDocument
    case address
    case financialAccount

    static func from(typeName: String?) -> DataPointType? {
        switch typeName {
        case "email": return .email
        case "phone": return .phoneNumber
        case "name": return .personalName
        case "address": return .address
        case "birthdate": return .birthDate
        case "id_document": return .idDocument
        default: return nil
        }
    }

    var description: String {
        switch self {
        case .personalName: return "name"
        case .phoneNumber: return "phone"
        case .email: return "email"
        case .address: return "address"
        case .birthDate: return "birthdate"
        case .idDocument: return "id_document"
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
        verification = nil
        verified = false
    }

    open func complete() -> Bool {
        return false
    }

    @objc func copyWithZone(_: NSZone?) -> AnyObject {
        let retVal = DataPoint(type: type, verified: verified)
        if let verification = verification {
            retVal.verification = verification.copy() as? Verification
        }
        return retVal
    }

    override public func isEqual(_ object: Any?) -> Bool {
        if let obj = object as? DataPoint {
            return obj.type == type &&
                obj.verification == verification &&
                obj.verified == verified &&
                obj.notSpecified == notSpecified
        } else {
            return false
        }
    }
}

@objc open class PersonalName: DataPoint {
    private let disposeBag = DisposeBag()
    open var firstName: Observable<String?> = Observable(nil)
    open var lastName: Observable<String?> = Observable(nil)

    public convenience init(firstName: String?, lastName: String?, verified: Bool? = false) {
        self.init(type: .personalName, verified: verified)
        self.firstName.send(firstName)
        self.lastName.send(lastName)
        self.firstName.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
        self.lastName.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    }

    @objc public convenience init(firstName: String?, lastName: String?, verified: Bool) {
        self.init(firstName: firstName, lastName: lastName, verified: verified as Bool?)
    }

    public convenience init() {
        self.init(firstName: nil, lastName: nil, verified: false)
    }

    override open func complete() -> Bool {
        return firstName.value != nil && lastName.value != nil
    }

    open func fullName() -> String? {
        if let firstNameStr = firstName.value, let lastNameStr = lastName.value {
            return firstNameStr + " " + lastNameStr
        } else if let firstNameStr = firstName.value {
            return firstNameStr
        } else if let lastNameStr = lastName.value {
            return lastNameStr
        }
        return nil
    }

    override func copyWithZone(_: NSZone?) -> AnyObject {
        let retVal = PersonalName(firstName: firstName.value, lastName: lastName.value, verified: verified)
        if let verification = verification {
            retVal.verification = verification.copy() as? Verification
        }
        return retVal
    }
}

public typealias AptoPhoneNumber = PhoneNumber
public typealias AptoEmail = Email
public typealias AptoBirthDate = BirthDate
public typealias AptoDocument = IdDocument
public typealias AptoAddress = Address

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

    @objc public convenience init(countryCode: Int, phoneNumber: String?, verified: Bool) {
        self.init(countryCode: countryCode, phoneNumber: phoneNumber, verified: verified as Bool?)
    }

    public convenience init() {
        self.init(countryCode: nil, phoneNumber: nil, verified: false)
    }

    override open func complete() -> Bool {
        return countryCode.value != nil && phoneNumber.value != nil
    }

    override func copyWithZone(_: NSZone?) -> AnyObject {
        let retVal = PhoneNumber(countryCode: countryCode.value, phoneNumber: phoneNumber.value,
                                 verified: verified)
        if let verification = verification {
            retVal.verification = verification.copy() as? Verification
        }
        return retVal
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countryCode.value = try container.decodeIfPresent(Int.self, forKey: .countryCode)
        phoneNumber.value = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        let verified = try container.decode(Bool.self, forKey: .verified)
        super.init(type: .phoneNumber, verified: verified)
        setUpObservers()
        self.verified = verified
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let countryCode = countryCode.value {
            try container.encode(countryCode, forKey: .countryCode)
        }
        if let phoneNumber = phoneNumber.value {
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
        countryCode.observeNext { [weak self] countryCode in
            self?.invalidateVerification()
            guard let countryCode = countryCode else { return }
            self?.country.send(Country(isoCode: PhoneHelper.sharedHelper().region(for: countryCode)))
        }.dispose(in: disposeBag)
        phoneNumber.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    }
}

@objc open class Email: DataPoint {
    private let disposeBag = DisposeBag()
    open var email: Observable<String?> = Observable(nil)

    public convenience init(email: String?, verified: Bool?, notSpecified: Bool?) {
        self.init(type: .email, verified: verified, notSpecified: notSpecified)
        self.email.send(email)
        self.email.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
        self.verified = verified
    }

    @objc public convenience init(email: String?, verified: Bool, notSpecified: Bool) {
        self.init(email: email, verified: verified as Bool?, notSpecified: notSpecified as Bool?)
    }

    public convenience init() {
        self.init(email: nil, verified: false, notSpecified: false)
    }

    override open func complete() -> Bool {
        if let notSpecified = notSpecified, notSpecified == true {
            return true
        }
        return email.value != nil
    }

    override func copyWithZone(_: NSZone?) -> AnyObject {
        let retVal = Email(email: email.value, verified: verified, notSpecified: notSpecified)
        if let verification = verification {
            retVal.verification = verification.copy() as? Verification
        }
        return retVal
    }
}

@objc open class BirthDate: DataPoint {
    private let disposeBag = DisposeBag()
    open var date: Observable<Date?> = Observable(nil)

    public convenience init(date: Date?, verified: Bool? = false) {
        self.init(type: .birthDate, verified: verified)
        self.date.send(date)
        self.date.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
        self.verified = verified
    }

    @objc public convenience init(date: Date?, verified: Bool) {
        self.init(date: date, verified: verified as Bool?)
    }

    public convenience init() {
        self.init(date: nil, verified: false)
    }

    override open func complete() -> Bool {
        return date.value != nil
    }

    override func copyWithZone(_: NSZone?) -> AnyObject {
        let retVal = BirthDate(date: date.value,
                               verified: verified)
        if let verification = verification {
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
        case .ssn: return "ssn"
        case .identityCard: return "identity_card"
        case .passport: return "passport"
        case .driversLicense: return "drivers_license"
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
        case .ssn: return "birthday-collector.id-document.type.ssn".podLocalized()
        case .identityCard: return "birthday-collector.id-document.type.identity-card".podLocalized()
        case .passport: return "birthday-collector.id-document.type.passport".podLocalized()
        case .driversLicense: return "birthday-collector.id-document.type.drivers-license".podLocalized()
        }
    }
}

@objc open class IdDocument: DataPoint {
    private let disposeBag = DisposeBag()
    open var documentType: Observable<IdDocumentType?> = Observable(nil)
    open var value: Observable<String?> = Observable(nil)
    open var country: Observable<Country?> = Observable(nil)

    public convenience init(documentType: IdDocumentType?, value: String?, country: Country?, verified: Bool? = false,
                            notSpecified: Bool? = false)
    {
        self.init(type: .idDocument, verified: verified, notSpecified: notSpecified)
        self.documentType.send(documentType)
        self.value.send(value)
        self.country.send(country)
        self.documentType.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
        self.value.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
        self.country.observeNext { [weak self] _ in self?.invalidateVerification() }.dispose(in: disposeBag)
    }

    @objc public convenience init(documentType: IdDocumentType, value: String?, verified: Bool, notSpecified: Bool) {
        self.init(documentType: documentType as IdDocumentType?,
                  value: value,
                  country: nil,
                  verified: verified as Bool?,
                  notSpecified: notSpecified as Bool?)
    }

    public convenience init() {
        self.init(documentType: nil, value: nil, country: nil)
    }

    override open func complete() -> Bool {
        if let notSpecified = notSpecified, notSpecified == true {
            return true
        }
        return value.value != nil
    }

    override func copyWithZone(_: NSZone?) -> AnyObject {
        let retVal = IdDocument(documentType: documentType.value, value: value.value, country: country.value,
                                verified: verified, notSpecified: notSpecified)
        if let verification = verification {
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

    public init(address: String?, apUnit: String?, country: Country?, city: String?, region: String?, zip: String?,
                verified: Bool? = false)
    {
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

    @objc public convenience init(address: String?, apUnit: String?, countryCode: String?, countryName: String?,
                                  city: String?, region: String?, zip: String?, verified: Bool)
    {
        let country: Country?
        if let countryCode = countryCode, let countryName = countryName {
            country = Country(isoCode: countryCode, name: countryName)
        } else {
            country = nil
        }
        self.init(address: address, apUnit: apUnit, country: country, city: city, region: region, zip: zip,
                  verified: verified)
    }

    public convenience init() {
        self.init(address: nil, apUnit: nil, country: nil, city: nil, region: nil, zip: nil, verified: false)
    }

    override open func complete() -> Bool {
        return address.value != nil && city.value != nil && region.value != nil && zip.value != nil
    }

    open func addressDescription() -> String? {
        if country.value?.isoCode == "US" {
            var addressComponents: [String] = []
            if let address = address.value {
                addressComponents.append(address)
            }
            if let city = city.value {
                addressComponents.append(city)
            }
            if let stateCode = region.value {
                addressComponents.append(stateCode)
            }
            if let zip = self.zip.value {
                addressComponents.append(zip)
            }
            return addressComponents.joined(separator: ", ")
        }
        return nil
    }

    override func copyWithZone(_: NSZone?) -> AnyObject {
        let retVal = Address(address: address.value, apUnit: apUnit.value, country: country.value,
                             city: city.value, region: region.value, zip: self.zip.value, verified: verified)
        if let verification = verification {
            retVal.verification = verification.copy() as? Verification
        }
        return retVal
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let verified = try container.decodeIfPresent(Bool.self, forKey: .verified) ?? false
        super.init(type: .address, verified: verified)
        address.send(try container.decodeIfPresent(String.self, forKey: .address))
        apUnit.send(try container.decodeIfPresent(String.self, forKey: .apUnit))
        country.send(try container.decodeIfPresent(Country.self, forKey: .country))
        city.send(try container.decodeIfPresent(String.self, forKey: .city))
        region.send(try container.decodeIfPresent(String.self, forKey: .region))
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

// MARK: - Datapoint equatable protocol

// swiftlint:disable operator_whitespace
func == (lhs: Email, rhs: Email) -> Bool {
    return lhs as DataPoint == rhs as DataPoint && lhs.email.value == rhs.email.value
}

func == (lhs: PhoneNumber, rhs: PhoneNumber) -> Bool {
    return lhs as DataPoint == rhs as DataPoint
        && lhs.countryCode.value == rhs.countryCode.value
        && lhs.phoneNumber.value == rhs.phoneNumber.value
}

func == (lhs: PersonalName, rhs: PersonalName) -> Bool {
    return lhs as DataPoint == rhs as DataPoint
        && lhs.firstName.value == rhs.firstName.value
        && lhs.lastName.value == rhs.lastName.value
}

func == (lhs: DataPoint, rhs: DataPoint) -> Bool {
    return lhs.type == rhs.type
        && lhs.notSpecified == rhs.notSpecified
        && lhs.verified == rhs.verified
        && ((lhs.verification == nil && rhs.verification == nil)
            || (lhs.verification != nil && rhs.verification != nil && lhs.verification! == rhs.verification!))
    // swiftlint:disable:previous force_unwrapping
}

func == (lhs: Address, rhs: Address) -> Bool {
    return lhs as DataPoint == rhs as DataPoint
        && lhs.address.value == rhs.address.value
        && lhs.apUnit.value == rhs.apUnit.value
        && lhs.country.value == rhs.country.value
        && lhs.city.value == rhs.city.value
        && lhs.region.value == rhs.region.value
        && lhs.zip.value == rhs.zip.value
}

func == (lhs: BirthDate, rhs: BirthDate) -> Bool {
    return lhs as DataPoint == rhs as DataPoint
        && lhs.date.value == rhs.date.value
}

func == (lhs: IdDocument, rhs: IdDocument) -> Bool {
    return lhs as DataPoint == rhs as DataPoint
        && lhs.documentType.value == rhs.documentType.value
        && lhs.value.value == rhs.value.value
        && lhs.country.value == rhs.country.value
}

// swiftlint:enable operator_whitespace
