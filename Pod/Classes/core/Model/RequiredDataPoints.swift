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
                configuration: RequiredDataPointConfigProtocol? = nil)
    {
        self.type = type
        self.verificationRequired = verificationRequired
        self.optional = optional
        self.configuration = configuration
        super.init()
    }

    @objc func copyWithZone(_: NSZone?) -> AnyObject {
        return RequiredDataPoint(type: type,
                                 verificationRequired: verificationRequired,
                                 optional: optional,
                                 configuration: configuration)
    }
}

func == (lhs: RequiredDataPoint, rhs: RequiredDataPoint) -> Bool { // swiftlint:disable:this operator_whitespace
    return lhs.type == rhs.type
        && lhs.verificationRequired == rhs.verificationRequired
        && lhs.optional == rhs.optional
}

@objc open class RequiredDataPointList: NSObject, Sequence {
    private var requiredDataPoints: [DataPointType: RequiredDataPoint]
    private var orderedDataPoints: [RequiredDataPoint]

    override public init() {
        requiredDataPoints = [:]
        orderedDataPoints = []
        super.init()
    }

    open func add(requiredDataPoint: RequiredDataPoint) {
        requiredDataPoints[requiredDataPoint.type] = requiredDataPoint
        if orderedDataPoints.firstIndex(where: { $0.type == requiredDataPoint.type }) == nil {
            orderedDataPoints.append(requiredDataPoint)
        }
    }

    open func removeDataPointsOf(type: DataPointType) {
        requiredDataPoints.removeValue(forKey: type)
        if let index = orderedDataPoints.firstIndex(where: { $0.type == type }) {
            orderedDataPoints.remove(at: index)
        }
    }

    open func getRequiredDataPointOf(type: DataPointType) -> RequiredDataPoint? {
        return requiredDataPoints[type]
    }

    open func count() -> Int {
        return requiredDataPoints.count
    }

    open func getMissingDataPoints(_ dataPointList: DataPointList) -> RequiredDataPointList {
        let retVal = RequiredDataPointList()
        for requiredDataPoint in orderedDataPoints {
            if requiredDataPoint.type == .financialAccount {
                continue
            }
            guard let userDataPoints = dataPointList.getDataPointsOf(type: requiredDataPoint.type) else {
                retVal.add(requiredDataPoint: requiredDataPoint)
                continue
            }
            if requiredDataPoint.verificationRequired {
                if userDataPoints.filter({ $0.verified == true }).isEmpty {
                    retVal.add(requiredDataPoint: requiredDataPoint)
                }
            }
        }
        return retVal
    }

    @objc func copyWithZone(_: NSZone?) -> AnyObject {
        let retVal = RequiredDataPointList()
        for requiredDataPoint in orderedDataPoints {
            retVal.add(requiredDataPoint: requiredDataPoint.copy() as! RequiredDataPoint) // swiftlint:disable:this force_cast
        }
        return retVal
    }

    public func makeIterator() -> Array<RequiredDataPoint>.Iterator {
        return orderedDataPoints.makeIterator()
    }
}
