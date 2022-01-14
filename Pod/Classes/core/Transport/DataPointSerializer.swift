//
//  DataPointSSerializer.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 24/02/16.
//
//

import Foundation

extension DataPointList: JSONSerializable {
    public func jsonSerialize() -> [String: AnyObject] {
        var data: [[String: AnyObject]] = []
        for dataPoints in dataPoints.values {
            for dataPoint in dataPoints {
                data.append(dataPoint.jsonSerialize())
            }
        }
        return [
            "type": "list" as AnyObject,
            "data": data as AnyObject,
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
        data["data_type"] = type.description as AnyObject
        return data
    }
}

public extension PersonalName {
    override func jsonSerialize() -> [String: AnyObject] {
        var data = super.jsonSerialize()
        data["first_name"] = firstName.value as AnyObject? ?? NSNull()
        data["last_name"] = lastName.value as AnyObject? ?? NSNull()
        return data
    }
}

public extension PhoneNumber {
    override func jsonSerialize() -> [String: AnyObject] {
        var data = super.jsonSerialize()
        if let countryCode = countryCode.value {
            data["country_code"] = countryCode as AnyObject
        } else {
            data["country_code"] = NSNull()
        }
        data["phone_number"] = phoneNumber.value as AnyObject? ?? NSNull()
        return data
    }
}

public extension Email {
    override func jsonSerialize() -> [String: AnyObject] {
        var data = super.jsonSerialize()
        data["email"] = email.value as AnyObject? ?? NSNull()
        return data
    }
}

public extension BirthDate {
    override func jsonSerialize() -> [String: AnyObject] {
        var data = super.jsonSerialize()
        data["date"] = date.value?.formatForJSONAPI() as AnyObject? ?? NSNull()
        return data
    }
}

public extension IdDocument {
    override func jsonSerialize() -> [String: AnyObject] {
        var data = super.jsonSerialize()
        data["doc_type"] = documentType.value?.description as AnyObject? ?? NSNull()
        data["value"] = value.value as AnyObject? ?? NSNull()
        data["country"] = country.value?.isoCode as AnyObject? ?? NSNull()
        if let notSpecified = notSpecified, notSpecified {
            data["not_specified"] = true as AnyObject
        }
        return data
    }
}

public extension Address {
    override func jsonSerialize() -> [String: AnyObject] {
        var data = super.jsonSerialize()
        data["street_one"] = address.value as AnyObject? ?? NSNull()
        data["street_two"] = apUnit.value as AnyObject? ?? NSNull()
        data["locality"] = city.value as AnyObject? ?? NSNull()
        data["region"] = region.value as AnyObject? ?? NSNull()
        data["postal_code"] = self.zip.value as AnyObject? ?? NSNull()
        data["country"] = country.value?.isoCode as AnyObject? ?? NSNull()
        return data
    }
}
