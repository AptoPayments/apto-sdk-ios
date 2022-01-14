//
//  NSObject.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 14/05/2017.
//
//

import Foundation

func == (lhs: [NSObject], rhs: [NSObject]) -> Bool { // swiftlint:disable:this operator_whitespace
    guard lhs.count == rhs.count else { return false }
    var lhsIterator = lhs.makeIterator()
    var rhsIterator = rhs.makeIterator()
    var isEqual = true
    while let lhsItem = lhsIterator.next(), let rhsItem = rhsIterator.next(), isEqual {
        isEqual = lhsItem == rhsItem
    }
    return isEqual
}
