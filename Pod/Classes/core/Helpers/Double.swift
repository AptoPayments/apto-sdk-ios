//
//  Double.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 04/03/16.
//
//

import Foundation

extension Double {
  public func format(decimalPlaces: Int) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.locale = Locale.current
    numberFormatter.maximumFractionDigits = decimalPlaces
    numberFormatter.minimumFractionDigits = decimalPlaces
    return numberFormatter.string(from: NSNumber(value: self))! // swiftlint:disable:this force_unwrapping
  }
}

// Perform a round to a number of significant decimal figures. The implementation is based in the algorithm from:
// https://en.wikipedia.org/wiki/Significant_figures
//
// Cannot add it inside the extension because there is a name collision between the _global_ round and pow functions and
// the methods of the Double struct.
public func round(_ num: Double, toSignificantDecimalFigures places: Int) -> Double {
  if num == 0 || places == 0 {
    return num.rounded()
  }
  var adjustedPlaces = places
  var number = Int(abs(num))
  while number > 0 {
    adjustedPlaces += 1
    number /= 10
  }
  let numb = floor(log10(abs(num))) + Double(1 - adjustedPlaces)
  return round(pow(10, -numb) * num) * pow(10, numb)
}
