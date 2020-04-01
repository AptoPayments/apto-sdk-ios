//
//  CardDetails.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 10/03/2020.
//

public struct CardDetails {
  public let expiration: String
  public let pan: String
  public let cvv: String
  public let month: UInt?
  public let year: UInt?

  init(expiration: String, pan: String, cvv: String) {
    self.expiration = expiration
    self.pan = pan
    self.cvv = cvv
    let decodedExpiration = decodeExpiration(expiration)
    self.month = decodedExpiration.month
    self.year = decodedExpiration.year
  }
}

fileprivate func decodeExpiration(_ exp: String) -> (month: UInt?, year: UInt?) {
  let separators = CharacterSet(charactersIn: "-/")
  let components = exp.components(separatedBy: separators)
  var year: UInt?
  var month: UInt?
  if components.count > 1 {
    year = UInt(components[0])
    month = UInt(components[1])
    if let unwrapped = year, unwrapped > 99 {
      year = unwrapped - 2000
    }
  }
  return (month: month, year: year)
}
