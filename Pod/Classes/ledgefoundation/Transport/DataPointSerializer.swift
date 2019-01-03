//
//  DataPointSSerializer.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 24/02/16.
//
//

import Foundation

extension DataPointList: JSONSerializable {
  public func jsonSerialize() -> [String: AnyObject] {
    var data: [[String: AnyObject]] = []
    for dataPoints in self.dataPoints.values {
      for dataPoint in dataPoints {
        data.append(dataPoint.jsonSerialize())
      }
    }
    return [
      "type": "list" as AnyObject,
      "data": data as AnyObject
    ]
  }
}

extension DataPoint: JSONSerializable {
  @objc public func jsonSerialize() -> [String: AnyObject] {
    var data = [String: AnyObject]()
    if let verification = verification {
      data["verification"] = verification.jsonSerialize() as AnyObject
    }
    if let notSpecified = notSpecified {
      data["not_specified"] = notSpecified as AnyObject
    }
    if let verified = verified {
      data["verified"] = verified as AnyObject
    }
    data["data_type"] = self.type.description as AnyObject
    return data
  }
}

extension PersonalName {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["first_name"] = self.firstName.value as AnyObject? ?? NSNull()
    data["last_name"] = self.lastName.value as AnyObject? ?? NSNull()
    return data
  }
}

extension PhoneNumber {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    if let countryCode = self.countryCode.value {
      data["country_code"] = countryCode as AnyObject
    }
    else {
      data["country_code"] = NSNull()
    }
    data["phone_number"] = self.phoneNumber.value as AnyObject? ?? NSNull()
    return data
  }
}

extension Email {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["email"] = self.email.value as AnyObject? ?? NSNull()
    return data
  }
}

extension BirthDate {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["date"] = self.date.value?.formatForJSONAPI() as AnyObject? ?? NSNull()
    return data
  }
}

extension IdDocument {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["doc_type"] = self.documentType.value?.description as AnyObject? ?? NSNull()
    data["value"] = self.value.value as AnyObject? ?? NSNull()
    data["country"] = self.country.value?.isoCode as AnyObject? ?? NSNull()
    if let notSpecified = self.notSpecified, notSpecified {
      data["not_specified"] = true as AnyObject
    }
    return data
  }
}

extension Address {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["street_one"] = self.address.value as AnyObject? ?? NSNull()
    data["street_two"] = self.apUnit.value as AnyObject? ?? NSNull()
    data["locality"] = self.city.value as AnyObject? ?? NSNull()
    data["region"] = self.region.value as AnyObject? ?? NSNull()
    data["postal_code"] = self.zip.value as AnyObject? ?? NSNull()
    data["country"] = self.country.value?.isoCode as AnyObject? ?? NSNull()
    return data
  }
}

extension Housing {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["housing_type_id"] = self.housingType.value?.housingTypeId as AnyObject? ?? NSNull()
    return data
  }
}

extension IncomeSource {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["income_type_id"] = self.incomeType.value?.incomeTypeId as AnyObject? ?? NSNull()
    data["salary_frequency_id"] = self.salaryFrequency.value?.salaryFrequencyId as AnyObject? ?? NSNull()
    return data
  }
}

extension Income {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["gross_annual_income"] = self.grossAnnualIncome.value as AnyObject? ?? NSNull()
    data["net_monthly_income"] = self.netMonthlyIncome.value as AnyObject? ?? NSNull()
    return data
  }
}

extension CreditScore {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["credit_range"] = self.creditRange.value as AnyObject? ?? NSNull()
    return data
  }
}

extension TimeAtAddress {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    if let value = self.timeAtAddress.value {
      data["time_at_address_id"] = value.timeAtAddressId as AnyObject
    }
    else {
      data["time_at_address_id"] = NSNull()
    }
    return data
  }
}

extension PaydayLoan {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["payday_loan"] = self.usedPaydayLoan.value as AnyObject? ?? NSNull()
    return data
  }
}

extension MemberOfArmedForces {
  public override func jsonSerialize() -> [String: AnyObject] {
    var data = super.jsonSerialize()
    data["member_of_armed_forces"] = self.memberOfArmedForces.value as AnyObject? ?? NSNull()
    return data
  }
}
