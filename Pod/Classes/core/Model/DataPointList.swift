//
//  DataPointList.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 16/05/2017.
//
//

import Foundation

@objc open class DataPointList: NSObject, Sequence {
    open var dataPoints: [DataPointType: [DataPoint]]
    private var orderedDataPoints: [DataPoint]

    @objc override public init() {
        dataPoints = [:]
        orderedDataPoints = []
        super.init()
    }

    @objc open func add(dataPoint: DataPoint) {
        orderedDataPoints.append(dataPoint)
        if var existingBag = dataPoints[dataPoint.type] {
            existingBag.append(dataPoint)
            dataPoints[dataPoint.type] = existingBag
            return
        }
        dataPoints[dataPoint.type] = [dataPoint]
    }

    @objc open func removeDataPointsOf(type: DataPointType) {
        if dataPoints[type] != nil {
            dataPoints.removeValue(forKey: type)
            orderedDataPoints.removeAll { $0.type == type }
        }
    }

    @objc open func replaceDataPointsOf(type: DataPointType, withDatapoint: DataPoint) {
        removeDataPointsOf(type: type)
        add(dataPoint: withDatapoint)
    }

    @objc open func getDataPointsOf(type: DataPointType) -> [DataPoint]? {
        return dataPoints[type]
    }

    @objc open func getForcingDataPointOf(type: DataPointType, defaultValue: DataPoint) -> DataPoint {
        if let retVal = dataPoints[type]?.first {
            return retVal
        }
        add(dataPoint: defaultValue)
        return defaultValue
    }

    open var isEmpty: Bool {
        return dataPoints.isEmpty
    }

    @objc func copyWithZone(_: NSZone?) -> AnyObject {
        let retVal = DataPointList()
        for dataPoint in orderedDataPoints {
            retVal.add(dataPoint: dataPoint.copy() as! DataPoint) // swiftlint:disable:this force_cast
        }
        return retVal
    }

    @objc public func filterNonCompletedDataPoints() -> DataPointList {
        let completeDatapoints = DataPointList()
        for datapointCategory in dataPoints.values {
            for datapoint in datapointCategory {
                if datapoint.complete() {
                    completeDatapoints.add(dataPoint: datapoint)
                }
            }
        }
        return completeDatapoints
    }

    public func makeIterator() -> Array<DataPoint>.Iterator {
        return orderedDataPoints.makeIterator()
    }

    public func currentCountry() -> Country? {
        for dataPoint in orderedDataPoints {
            if let countryRestricted = dataPoint as? CountryRestrictedDataPoint,
               let country = countryRestricted.country.value
            {
                return country
            }
        }
        return nil
    }
}

public extension DataPointList {
    // swiftlint:disable force_cast
    var nameDataPoint: PersonalName {
        return getForcingDataPointOf(type: .personalName, defaultValue: PersonalName()) as! PersonalName
    }

    var emailDataPoint: Email {
        return getForcingDataPointOf(type: .email, defaultValue: Email()) as! Email
    }

    var phoneDataPoint: PhoneNumber {
        return getForcingDataPointOf(type: .phoneNumber, defaultValue: PhoneNumber()) as! PhoneNumber
    }

    var addressDataPoint: Address {
        return getForcingDataPointOf(type: .address, defaultValue: Address()) as! Address
    }

    var birthDateDataPoint: BirthDate {
        return getForcingDataPointOf(type: .birthDate, defaultValue: BirthDate()) as! BirthDate
    }

    var idDocumentDataPoint: IdDocument {
        return getForcingDataPointOf(type: .idDocument, defaultValue: IdDocument()) as! IdDocument
    }
    // swiftlint:enable force_cast
}

public extension DataPointList {
    func modifiedDataPoints(compareWith dataPointList: DataPointList) -> DataPointList {
        let difference = DataPointList()
        for (key, otherDataPoints) in dataPointList.dataPoints {
            let ownDataPoints = getDataPointsOf(type: key)
            if ownDataPoints == nil {
                // The datapoints are not in the current datapoint list. They are additions
                for dataPoint in otherDataPoints {
                    difference.add(dataPoint: dataPoint)
                }
            } else {
                // Compare them (only the first one in the list, lists will be removed soon, there's only one datapoint
                // per datapoint type in the list)
                if let ownDataPoint = ownDataPoints?.first,
                   let otherDataPoint = otherDataPoints.first,
                   ownDataPoint.modifiedFrom(dataPoint: otherDataPoint)
                {
                    difference.add(dataPoint: otherDataPoint)
                }
            }
        }
        return difference
    }
}
