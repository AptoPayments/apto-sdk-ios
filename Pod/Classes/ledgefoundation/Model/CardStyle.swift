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

public struct CardStyle {
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
