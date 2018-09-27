//
//  Dictionary.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 11/11/2017.
//

import Foundation

func += <K, V> (left: inout [K: V], right: [K: V]) {
  for (key, value) in right {
    left[key] = value
  }
}
