//
//  RequiredDataPointConfiguration.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 04/10/2018.
//

import SwiftyJSON

public struct AllowedCountriesConfiguration: RequiredDataPointConfigProtocol {
  public let allowedCountries: [Country]
}

extension AllowedCountriesConfiguration {
  init(allowedCountries: [Country]?) {
    let allowedCountries: [Country] = allowedCountries ?? [Country.defaultCountry]
    self.init(allowedCountries: allowedCountries)
  }
}

public struct AllowedIdDocumentTypesConfiguration: RequiredDataPointConfigProtocol {
  public let allowedDocumentTypes: [Country: [IdDocumentType]]

  public init(allowedDocumentTypes: [Country: [IdDocumentType]]) {
    if !allowedDocumentTypes.isEmpty {
      self.allowedDocumentTypes = allowedDocumentTypes
    }
    else {
      self.allowedDocumentTypes = [Country.defaultCountry: [.ssn]]
    }
  }
}

extension AllowedIdDocumentTypesConfiguration {
  init(allowedDocumentTypes: [Country: [IdDocumentType]]?) {
    let allowedDocumentTypes = allowedDocumentTypes ?? [:]
    self.init(allowedDocumentTypes: allowedDocumentTypes)
  }
}

extension JSON {
  var allowedCountriesRequiredDataPointConfig: AllowedCountriesConfiguration {
    let allowedCountries = self["allowed_countries"].allowedCountries
    return AllowedCountriesConfiguration(allowedCountries: allowedCountries)
  }

  var allowedIdDocumentTypesRequiredDataPointConfig: AllowedIdDocumentTypesConfiguration {
    var allowedDocumentTypes = [Country: [IdDocumentType]]()
    self["allowed_document_types"].dictionary?.forEach { isoCode, json in
      let country = Country(isoCode: isoCode)
      let documentTypes = json.arrayValue.compactMap {
        return IdDocumentType.from(string: $0.stringValue)
      }
      allowedDocumentTypes[country] = documentTypes
    }
    return AllowedIdDocumentTypesConfiguration(allowedDocumentTypes: allowedDocumentTypes)
  }
}
