//
//  RequiredDataPoints.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 16/05/2017.
//
//

import Foundation

public protocol RequiredDataPointConfigProtocol {}

@objc open class RequiredDataPoint: NSObject {
  public let type: DataPointType
  public let verificationRequired: Bool
  public let optional: Bool
  public let configuration: RequiredDataPointConfigProtocol?

  public init(type: DataPointType,
              verificationRequired: Bool,
              optional: Bool,
              configuration: RequiredDataPointConfigProtocol? = nil) {
    self.type = type
    self.verificationRequired = verificationRequired
    self.optional = optional
    self.configuration = configuration
    super.init()
  }

  @objc func copyWithZone(_ zone: NSZone?) -> AnyObject {
    return RequiredDataPoint(type: self.type,
                             verificationRequired: self.verificationRequired,
                             optional: self.optional,
                             configuration: self.configuration)
  }
}

func ==(lhs: RequiredDataPoint, rhs: RequiredDataPoint) -> Bool {
  return lhs.type == rhs.type
    && lhs.verificationRequired == rhs.verificationRequired
    && lhs.optional == rhs.optional
}

@objc open class RequiredDataPointList: NSObject, Sequence {
  private var requiredDataPoints: [DataPointType: RequiredDataPoint]
  private var orderedDataPoints: [RequiredDataPoint]

  public override init() {
    self.requiredDataPoints = [:]
    self.orderedDataPoints = []
    super.init()
  }

  open func add(requiredDataPoint: RequiredDataPoint) {
    requiredDataPoints[requiredDataPoint.type] = requiredDataPoint
    if orderedDataPoints.firstIndex(where: { $0.type == requiredDataPoint.type }) == nil {
      orderedDataPoints.append(requiredDataPoint)
    }
  }

  open func removeDataPointsOf(type: DataPointType) {
    if let _ = requiredDataPoints[type] {
      requiredDataPoints.removeValue(forKey: type)
    }
    if let index = orderedDataPoints.firstIndex(where: { $0.type == type }) {
      orderedDataPoints.remove(at: index)
    }
  }

  open func getRequiredDataPointOf(type: DataPointType) -> RequiredDataPoint? {
    return requiredDataPoints[type]
  }

  open func count() -> Int {
    return self.requiredDataPoints.count
  }

  open func getMissingDataPoints(_ dataPointList: DataPointList) -> RequiredDataPointList {
    let retVal = RequiredDataPointList()
    for requiredDataPoint in self.orderedDataPoints {
      if requiredDataPoint.type == .financialAccount {
        continue
      }
      guard let userDataPoints = dataPointList.getDataPointsOf(type: requiredDataPoint.type) else {
        retVal.add(requiredDataPoint: requiredDataPoint)
        continue
      }
      if requiredDataPoint.verificationRequired {
        var found = false
        for userDataPoint in userDataPoints {
          if userDataPoint.verified == true {
            found = true
          }
        }
        if !found {
          retVal.add(requiredDataPoint: requiredDataPoint)
        }
      }
    }
    return retVal
  }

  @objc func copyWithZone(_ zone: NSZone?) -> AnyObject {
    let retVal = RequiredDataPointList()
    for requiredDataPoint in self.orderedDataPoints {
      retVal.add(requiredDataPoint: requiredDataPoint.copy() as! RequiredDataPoint)
    }
    return retVal
  }

  public func makeIterator() -> Array<RequiredDataPoint>.Iterator {
    return orderedDataPoints.makeIterator()
  }
}
