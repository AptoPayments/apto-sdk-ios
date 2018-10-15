//
//  MutableDataPoints.swift
//  Pods
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
    return self.verificationModifiedFrom(dataPoint: dataPoint) ||
      self.notSpecified != dataPoint.notSpecified
  }

  func verificationModifiedFrom(dataPoint: DataPoint) -> Bool {
    if let otherVerification = dataPoint.verification {
      if let ownVerification = self.verification {
        return !(otherVerification == ownVerification)
      }
      else {
        return true
      }
    }
    return false
  }

  func notSpecifiedModifiedFrom(dataPoint: DataPoint) -> Bool {
    return self.notSpecified != dataPoint.notSpecified
  }
}

extension PersonalName {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? PersonalName else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.firstName.value != rhs.firstName.value
      || self.lastName.value != rhs.lastName.value
  }
}

extension PhoneNumber {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? PhoneNumber else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.countryCode.value != rhs.countryCode.value
      || self.phoneNumber.value != rhs.phoneNumber.value
  }
}

extension Email {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? Email else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.email.value != rhs.email.value
  }
}

extension BirthDate {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? BirthDate else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.date.value != rhs.date.value
  }
}

extension IdDocument {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? IdDocument else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.documentType.value != rhs.documentType.value
      || self.value.value != rhs.value.value
  }
}

extension Address {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? Address else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.address.value != rhs.address.value
      || self.apUnit.value != rhs.apUnit.value
      || self.country.value != rhs.country.value
      || self.city.value != rhs.city.value
      || self.region.value != rhs.region.value
      || self.zip.value != rhs.zip.value
  }
}

extension Housing {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? Housing else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.housingType.value != rhs.housingType.value
  }
}

extension IncomeSource {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? IncomeSource else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.salaryFrequency.value != rhs.salaryFrequency.value
      || self.incomeType.value != rhs.incomeType.value
  }
}

extension Income {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? Income else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.netMonthlyIncome.value != rhs.netMonthlyIncome.value
      || self.grossAnnualIncome.value != rhs.grossAnnualIncome.value
  }
}

extension CreditScore {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? CreditScore else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.creditRange.value != rhs.creditRange.value
  }
}

extension PaydayLoan {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? PaydayLoan else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.usedPaydayLoan.value != rhs.usedPaydayLoan.value
  }
}

extension MemberOfArmedForces {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? MemberOfArmedForces else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.memberOfArmedForces.value != rhs.memberOfArmedForces.value
  }
}

extension TimeAtAddress {
  override func modifiedFrom(dataPoint: DataPoint) -> Bool {
    guard let rhs = dataPoint as? TimeAtAddress else {
      return true
    }
    return (self as DataPoint).verificationModifiedFrom(dataPoint: dataPoint as DataPoint)
      || (self as DataPoint).notSpecifiedModifiedFrom(dataPoint: dataPoint as DataPoint)
      || self.timeAtAddress.value != rhs.timeAtAddress.value
  }
}
