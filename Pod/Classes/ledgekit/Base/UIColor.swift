//
//  UIColor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/01/2017.
//
//

import Foundation

extension UIColor {
  
  static public func colorFromHexString (_ hex: String, alpha: Double = 1.0) -> UIColor? {
    let scanner = Scanner(string: hex)
    var hexNumber: UInt64 = 0
    if scanner.scanHexInt64(&hexNumber) {
      let red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
      let green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
      let blue = CGFloat((hexNumber & 0x0000ff)) / 255
      return UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha) )
    }
    return nil
  }
  
  static public func colorFromHex (_ hex: Int, alpha: Double = 1.0) -> UIColor {
    let red = Double((hex & 0xFF0000) >> 16) / 255.0
    let green = Double((hex & 0xFF00) >> 8) / 255.0
    let blue = Double((hex & 0xFF)) / 255.0
    return UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha) )
  }
  
}

func colorize(_ hex: Int, alpha: Double = 1.0) -> UIColor {
  return UIColor.colorFromHex(hex, alpha: alpha)
}

func colorizeFromString(_ hex: String, alpha: Double = 1.0) -> UIColor? {
  return UIColor.colorFromHexString(hex, alpha: alpha)
}
