//
//  DataPointList.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 16/05/2017.
//
//

import Foundation

@objc open class DataPointList: NSObject {
  open var dataPoints: [DataPointType: [DataPoint]]

  @objc public override init() {
    self.dataPoints = [:]
    super.init()
  }

  @objc open func add(dataPoint: DataPoint) {
    if var existingBag = dataPoints[dataPoint.type] {
      existingBag.append(dataPoint)
      dataPoints[dataPoint.type] = existingBag
      return
    }
    dataPoints[dataPoint.type] = [dataPoint]
  }

  @objc open func removeDataPointsOf(type: DataPointType) {
    if let _ = dataPoints[type] {
      dataPoints.removeValue(forKey: type)
    }
  }

  @objc open func replaceDataPointsOf(type: DataPointType, withDatapoint: DataPoint) {
    self.removeDataPointsOf(type: type)
    self.add(dataPoint: withDatapoint)
  }

  @objc open func getDataPointsOf(type: DataPointType) -> [DataPoint]? {
    return dataPoints[type]
  }

  @objc open func getForcingDataPointOf(type: DataPointType, defaultValue: DataPoint) -> DataPoint {
    if let _ = dataPoints[type], let retVal = dataPoints[type]!.first {
      return retVal
    }
    self.add(dataPoint: defaultValue)
    return defaultValue
  }

  @objc func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = DataPointList()
    for dataPoints in self.dataPoints.values {
      for dataPoint in dataPoints {
        retVal.add(dataPoint: dataPoint.copy() as! DataPoint)
      }
    }
    return retVal
  }

  @objc func filterNonCompletedDataPoints() -> DataPointList {
    let completeDatapoints = DataPointList()
    for datapointCategory in self.dataPoints.values {
      for datapoint in datapointCategory {
        if datapoint.complete() {
          completeDatapoints.add(dataPoint: datapoint)
        }
      }
    }
    return completeDatapoints
  }
}

public extension DataPointList {
  var nameDataPoint:PersonalName {
    return getForcingDataPointOf(type:.personalName, defaultValue:PersonalName()) as! PersonalName
  }
  var emailDataPoint:Email {
    return getForcingDataPointOf(type:.email, defaultValue:Email()) as! Email
  }
  var phoneDataPoint:PhoneNumber {
    return getForcingDataPointOf(type:.phoneNumber, defaultValue:PhoneNumber()) as! PhoneNumber
  }
  var addressDataPoint:Address {
    return getForcingDataPointOf(type:.address, defaultValue:Address()) as! Address
  }
  var housingDataPoint:Housing {
    return getForcingDataPointOf(type:.housing, defaultValue:Housing()) as! Housing
  }
  var incomeDataPoint:Income {
    return getForcingDataPointOf(type:.income, defaultValue:Income()) as! Income
  }
  var incomeSourceDataPoint:IncomeSource {
    return getForcingDataPointOf(type:.incomeSource, defaultValue:IncomeSource()) as! IncomeSource
  }
  var creditScoreDataPoint:CreditScore {
    return getForcingDataPointOf(type:.creditScore, defaultValue:CreditScore()) as! CreditScore
  }
  var birthDateDataPoint:BirthDate {
    return getForcingDataPointOf(type:.birthDate, defaultValue:BirthDate()) as! BirthDate
  }
  var SSNDataPoint:SSN {
    return getForcingDataPointOf(type:.ssn, defaultValue:SSN()) as! SSN
  }
  var paydayLoanDataPoint:PaydayLoan {
    return getForcingDataPointOf(type:.paydayLoan, defaultValue:PaydayLoan()) as! PaydayLoan
  }
  var memberOfArmedForcesDataPoint:MemberOfArmedForces {
    return getForcingDataPointOf(type:.memberOfArmedForces, defaultValue:MemberOfArmedForces()) as! MemberOfArmedForces
  }
  var timeAtAddressDataPoint:TimeAtAddress {
    return getForcingDataPointOf(type:.timeAtAddress, defaultValue:TimeAtAddress()) as! TimeAtAddress
  }
}

extension DataPointList: Sequence {
  public func makeIterator() -> DataPointListGenerator {
    return DataPointListGenerator(dataPointList: self)
  }

  public struct DataPointListGenerator : IteratorProtocol {

    var dataPoints: [DataPoint] = []
    var index = 0

    init(dataPointList: DataPointList) {
      for value in dataPointList.dataPoints.values {
        for dataPoint in value {
          dataPoints.append(dataPoint)
        }
      }
    }

    public mutating func next() -> DataPoint? {
      return index < dataPoints.count ? dataPoints[index] : nil
    }
  }
}

extension DataPointList {

  func modifiedDataPoints(compareWith dataPointList:DataPointList) -> DataPointList {
    let difference = DataPointList()
    for (key, otherDataPoints) in dataPointList.dataPoints {
      let ownDataPoints = self.getDataPointsOf(type: key)
      if ownDataPoints == nil {
        // The datapoints are not in the current datapoint list. They are additions
        for dataPoint in otherDataPoints {
          difference.add(dataPoint: dataPoint)
        }
      }
      else {
        // Compare them (only the first one in the list, lists will be removed soon, there's only one datapoint
        // per datapoint type in the list)
        if let ownDataPoint = ownDataPoints?.first, let otherDataPoint = otherDataPoints.first, ownDataPoint.modifiedFrom(dataPoint: otherDataPoint) {
          difference.add(dataPoint: otherDataPoint)
        }
      }
    }
    return difference
  }

}
