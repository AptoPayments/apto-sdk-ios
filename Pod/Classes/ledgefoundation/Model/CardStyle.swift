//
//  CardStyle.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 31/10/2018.
//

import SwiftyJSON

public enum CardBackgroundStyle {
  case image(url: URL)
  case color(color: UIColor)
}

extension CardBackgroundStyle: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if container.contains(.image) {
      let url = try container.decode(URL.self, forKey: .image)
      self = .image(url: url)
    }
    else {
      let codableColor = try container.decode(UIColor.CodableWrapper.self, forKey: .color)
      self = .color(color: codableColor.value)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .image(let url):
      try container.encode(url, forKey: .image)
    case .color(let color):
      try container.encode(UIColor.CodableWrapper(color), forKey: .color)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case image
    case color
  }
}

public struct CardStyle: Codable {
  public let background: CardBackgroundStyle
}

extension JSON {
  var cardStyle: CardStyle? {
    guard let background = self["background"].cardBackgroundStyle else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse Card Style \(self)"))
      return nil
    }
    return CardStyle(background: background)
  }

  var cardBackgroundStyle: CardBackgroundStyle? {
    guard let rawBackgroundType = self["background_type"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse Card Background Style \(self)"))
      return nil
    }
    if rawBackgroundType == "image",
      let rawBackgroundImage = self["background_image"].string,
      let backgroundImageURL = URL.init(string: rawBackgroundImage) {
      return CardBackgroundStyle.image(url: backgroundImageURL)
    }
    if rawBackgroundType == "color",
      let rawColor = self["background_color"].string,
      let color = UIColor.colorFromHexString(rawColor) {
      return CardBackgroundStyle.color(color: color)
    }
    return nil
  }

}
