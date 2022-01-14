//
//  MutableDataPoints.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 05/07/2018.
//
//

// MARK: - Datapoint modification checking

protocol MutableDatapoint {
    func modifiedFrom(dataPoint: DataPoint) -> Bool
}

extension DataPoint: MutableDatapoint {
    @objc func modifiedFrom(dataPoint: DataPoint) -> Bool {
        return verificationModifiedFrom(dataPoint: dataPoint) ||
            notSpecified != dataPoint.notSpecified
    }

    func verificationModifiedFrom(dataPoint: DataPoint) -> Bool {
        if let otherVerification = dataPoint.verification {
            if let ownVerification = verification {
                return !(otherVerification == ownVerification)
            } else {
                return true
            }
        }
        return false
    }

    func notSpecifiedModifiedFrom(dataPoint: DataPoint) -> Bool {
        return notSpecified != dataPoint.notSpecified
    }
}

extension PersonalName {
    override func modifiedFrom(dataPoint: DataPoint) -> Bool {
        guard let rhs = dataPoint as? PersonalName else {
            return true
        }
        return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
            || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
            || firstName.value != rhs.firstName.value
            || lastName.value != rhs.lastName.value
    }
}

extension PhoneNumber {
    override func modifiedFrom(dataPoint: DataPoint) -> Bool {
        guard let rhs = dataPoint as? PhoneNumber else {
            return true
        }
        return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
            || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
            || countryCode.value != rhs.countryCode.value
            || phoneNumber.value != rhs.phoneNumber.value
    }
}

extension Email {
    override func modifiedFrom(dataPoint: DataPoint) -> Bool {
        guard let rhs = dataPoint as? Email else {
            return true
        }
        return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
            || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
            || email.value != rhs.email.value
    }
}

extension BirthDate {
    override func modifiedFrom(dataPoint: DataPoint) -> Bool {
        guard let rhs = dataPoint as? BirthDate else {
            return true
        }
        return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
            || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
            || date.value != rhs.date.value
    }
}

extension IdDocument {
    override func modifiedFrom(dataPoint: DataPoint) -> Bool {
        guard let rhs = dataPoint as? IdDocument else {
            return true
        }
        return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
            || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
            || documentType.value != rhs.documentType.value
            || value.value != rhs.value.value
    }
}

extension Address {
    override func modifiedFrom(dataPoint: DataPoint) -> Bool {
        guard let rhs = dataPoint as? Address else {
            return true
        }
        return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
            || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
            || address.value != rhs.address.value
            || apUnit.value != rhs.apUnit.value
            || country.value != rhs.country.value
            || city.value != rhs.city.value
            || region.value != rhs.region.value
            || self.zip.value != rhs.zip.value
    }
}
