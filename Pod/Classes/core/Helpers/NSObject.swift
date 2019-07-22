//
//  NSObject.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 14/05/2017.
//
//

import Foundation

func ==(lhs: [NSObject], rhs: [NSObject]) -> Bool
{
  guard lhs.count == rhs.count else { return false }
  var i1 = lhs.makeIterator()
  var i2 = rhs.makeIterator()
  var isEqual = true
  while let e1 = i1.next(), let e2 = i2.next(), isEqual
  {
    isEqual = e1 == e2
  }
  return isEqual
}
