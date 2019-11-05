//
//  UIColor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/01/2017.
//
//

import Foundation

extension UIColor {
  static public func colorFromHexString(_ hex: String, alpha: Double = 1.0) -> UIColor? {
    let scanner = Scanner(string: hex)
    var hexNumber: UInt64 = 0
    if scanner.scanHexInt64(&hexNumber) {
      let red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
      let green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
      let blue = CGFloat((hexNumber & 0x0000ff)) / 255
      return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    return nil
  }

  static public func colorFromHex(_ hex: Int, alpha: Double = 1.0) -> UIColor {
    let red = Double((hex & 0xFF0000) >> 16) / 255.0
    let green = Double((hex & 0xFF00) >> 8) / 255.0
    let blue = Double((hex & 0xFF)) / 255.0
    return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
  }

  // Calculated using the algorithm described in here:
  // http://particletree.com/notebook/calculating-color-contrast-for-legible-text/
  public var isLight: Bool {
    var colorBrightness: CGFloat = 0
    if cgColor.colorSpace?.model == CGColorSpaceModel.rgb, let components = cgColor.components {
      colorBrightness = (components[0] * 299 + components[1] * 587 + components[2] * 114) / CGFloat(1000)
    }
    else {
      getWhite(&colorBrightness, alpha: nil)
    }
    return colorBrightness > 0.7
  }
}

public func colorize(_ hex: Int, alpha: Double = 1.0) -> UIColor {
  return UIColor.colorFromHex(hex, alpha: alpha)
}

func colorizeFromString(_ hex: String, alpha: Double = 1.0) -> UIColor? {
  return UIColor.colorFromHexString(hex, alpha: alpha)
}

// MARK: - Codable
// Extracted from the Advanced Swift Book
extension UIColor {
  struct CodableWrapper: Codable {
    let value: UIColor

    init(_ value: UIColor) {
      self.value = value
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let red = try container.decode(CGFloat.self, forKey: .red)
      let green = try container.decode(CGFloat.self, forKey: .green)
      let blue = try container.decode(CGFloat.self, forKey: .blue)
      let alpha = try container.decode(CGFloat.self, forKey: .alpha)
      self.value = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func encode(to encoder: Encoder) throws {
      // Throw error if color isn't convertible to RGBA
      guard let (red, green, blue, alpha) = value.rgba else {
        let errorContext = EncodingError.Context(codingPath: encoder.codingPath,
                                                 debugDescription: "Unsupported color format: \(value)")
        throw EncodingError.invalidValue(value, errorContext)
      }
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(red, forKey: .red)
      try container.encode(green, forKey: .green)
      try container.encode(blue, forKey: .blue)
      try container.encode(alpha, forKey: .alpha)
    }

    enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
      case red
      case green
      case blue
      case alpha
    }
  }

  var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? { // swiftlint:disable:this large_tuple
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return (red: red, green: green, blue: blue, alpha: alpha)
    }
    else {
      return nil
    }
  }
}
