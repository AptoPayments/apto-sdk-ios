//
//  AddressManager.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 02/02/16.
//
//

import Foundation
import GoogleKit

open class AddressManager {
  private var queries = [GKQuery]()

  public static func defaultManager(apiKey: String? = nil) -> AddressManager {
    guard let sharedValidator = AddressManager.sharedValidator else {
      let addressManager = AddressManager(apiKey: apiKey)
      AddressManager.sharedValidator = addressManager
      return addressManager
    }
    return sharedValidator
  }

  public init(apiKey: String?) {
    guard let apiKey = apiKey else {
      return
    }
    GKQuery.provideAPIKey(apiKey)
  }

  open func validate(address: Address, result: @escaping Result<ShiftGeocoderPlace, NSError>.Callback) {
    self.geocode(address: address) { locations in
      switch locations {
      case .failure(let error):
        result(.failure(error))
      case .success(let location):
        result(.success(location))
      }
    }
  }

  open func geocode(address: Address, result: @escaping Result<ShiftGeocoderPlace, NSError>.Callback) {
    let query = ShiftGeocoderQuery()
    guard let addressDescription = address.addressDescription() else {
      result(.failure(ServiceError(code: .invalidAddress)))
      return
    }
    query.address = addressDescription
    query.region = address.country.value?.isoCode
    if let country = address.country.value {
      query.components = ["country:\(country.isoCode)"]
    }
    query.lookupLocation { (results, error) -> Void in
      if let error = error {
        result(Result.failure(error as NSError))
      }
      else {
        guard let results = results as? [ShiftGeocoderPlace], !results.isEmpty else {
          result(.failure(ServiceError(code: .invalidAddress)))
          return
        }
        if address.zip.value == nil {
          guard let firstResult = results.first, firstResult.isValidAddress() else {
            result(.failure(ServiceError(code: .invalidAddress)))
            return
          }
          result(Result.success(firstResult))
          return
        }
        else {
          if let found = results.index(where: { $0.postalCode == address.zip.value }) {
            let obj = results[found]
            result(Result.success(obj))
            return
          }
          else {
            result(.failure(ServiceError(code: .invalidAddress)))
            return
          }
        }
      }
    }
  }

  open func countryList() -> [Country] {
    let isoCountryCodes = Locale.isoRegionCodes
    let countries = isoCountryCodes.compactMap { (isoCode: String) -> (Country?) in
      let identifier = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: isoCode])
      let countryName = (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: identifier)
      guard let finalCountryName = countryName else {
        return nil
      }
      return Country(isoCode: isoCode, name: finalCountryName)
    }
    return countries
  }

  open func statesFor(country: String) -> [State]? {
    return self.stateStorage.getStates(country: country)
  }

  open func getStateBy(_ country: String, isoCode: String) -> State? {
    return self.stateStorage.getStateBy(country, isoCode: isoCode)
  }

  open func getStateBy(_ country: String, name: String) -> State? {
    return self.stateStorage.getStateBy(country, name: name)
  }

  open func autoComplete(address: String,
                         countries: [Country],
                         completion: @escaping Result<[Place], NSError>.Callback) {
    queries.forEach { $0.cancel() }

    let query = GKPlaceAutocompleteQuery()
    query.input = address
    query.types = ["address"]
    var countriesParam = [String]()
    countries.forEach {
      countriesParam.append("country:\($0.isoCode.lowercased())")
    }
    var components = countriesParam.joined(separator: "%7C")
    if let uuid = UIDevice.current.identifierForVendor?.uuidString {
      components.append("&sessiontoken=" + uuid)
    }
    query.components = [components]
    if let languageCode = Locale.current.languageCode {
      query.language = languageCode
    }

    queries.append(query)

    query.fetchPlaces { places, error in
      if let places = places as? [GKPlaceAutocomplete], !places.isEmpty {
        let retVal = places.compactMap {
          return Place(id: $0.placeId, name: $0.textDescription)
        }
        completion(.success(retVal))
      }
      else {
        if let error = error {
          completion(.failure(error as NSError))
        }
        else {
          completion(.failure(BackendError(code: .other)))
        }
      }
    }
  }

  open func placeDetails(placeId: String, completion: @escaping Result<Address, NSError>.Callback) {
    let placeQuery = PlaceDetailsQuery()
    placeQuery.placeId = placeId
    if let languageCode = Locale.current.languageCode {
      placeQuery.language = languageCode
    }
    placeQuery.fetchDetails { [weak self] placeDetails, error in
      if let placeDetails = placeDetails as? PlaceDetails {
        let address = Address(address: placeDetails.name,
                              apUnit: nil,
                              country: Country(isoCode: placeDetails.country),
                              city: self?.cityName(for: placeDetails),
                              region: placeDetails.administrativeAreaLevel1,
                              zip: placeDetails.postalCode)
        address.formattedAddress = placeDetails.formattedAddress
        completion(.success(address))
      }
      else {
        if let error = error {
          completion(.failure(error as NSError))
        }
        else {
          completion(.failure(BackendError(code: .other)))
        }
      }
    }
  }

  // MARK: - Private methods and attributes

  private func cityName(for placeDetails: PlaceDetails) -> String {
    return placeDetails.locality ?? (placeDetails.postalTown ?? placeDetails.administrativeAreaLevel2)
  }

  static var sharedValidator: AddressManager?
  let stateStorage = StateStorage()
}

open class ShiftGeocoderPlace: GKGeocoderPlace {
  var types: [String]?

  override init(dictionary: [AnyHashable: Any]) {
    super.init(dictionary: dictionary)
    guard let types = dictionary["types"] as? [String] else {
      return
    }
    self.types = types
  }

  open func isValidAddress() -> Bool {
    guard let types = self.types else {
      return false
    }
    return types.contains("street_address")
  }

  open func isValidZipCode() -> Bool {
    guard let types = self.types else {
      return false
    }
    return types.contains("postal_code")
  }
}

open class ShiftGeocoderQuery: GKGeocoderQuery {
  // swiftlint:disable:next implicitly_unwrapped_optional
  override open func handleQueryResponse(_ response: [AnyHashable: Any]!, error: Error!) {
    if error != nil {
      DispatchQueue.main.async {
        self.completionHandler?(nil, error)
        return
      }
    }

    guard response != nil else {
      DispatchQueue.main.async {
        self.completionHandler?(nil, error)
      }
      return
    }

    guard let results = response["results"] as? [[AnyHashable: Any]] else {
      DispatchQueue.main.async {
        self.completionHandler?(nil, error)
      }
      return
    }

    var places = [ShiftGeocoderPlace]()
    for result in results {
      places.append(ShiftGeocoderPlace(dictionary: result))
    }

    DispatchQueue.main.async {
      self.completionHandler?(places, nil)
    }
  }
}

public struct Place {
  public let id: String
  public let name: String
}

class PlaceDetailsQuery: GKPlaceDetailsQuery {
  // We need to use the short_name returned by the Google Maps API for the country and for the
  // administrative_area_level_1. Instead of rewriting the full feature we are modifying the response to set the
  // long_name equal to the short_name for those two attributes.
  override func handleQueryResponse(_ response: [AnyHashable: Any]!, error: Error!) {
    if let error = error {
      super.handleQueryResponse(nil, error: error)
      return
    }

    guard var dictionary = response["result"] as? [String: Any] else {
      super.handleQueryResponse(nil, error: BackendError(code: .other))
      return
    }
    var components = [Any]()
    if let addressComponents = dictionary["address_components"] as? [Dictionary<String, Any>] {
      for addressComponent in addressComponents {
        guard let types = addressComponent["types"] as? [String],
              let type = types.first,
              let shortName = addressComponent["short_name"] as? String else {
          continue
        }
        if type == "administrative_area_level_1" || type == "country" {
          var component = addressComponent
          component["long_name"] = shortName
          components.append(component)
        }
        else {
          components.append(addressComponent)
        }
      }
    }
    dictionary["address_components"] = components
    DispatchQueue.main.async {
      if let completionHandler = self.completionHandler {
        completionHandler(PlaceDetails(dictionary: dictionary), nil)
      }
    }
  }
}

class PlaceDetails: GKPlaceDetails {
  let postalTown: String?

  override init!(dictionary: [AnyHashable: Any]!) {
    var postalTown: String? = nil
    if let addressComponents = dictionary["address_components"] as? [Dictionary<String, Any>] {
      for addressComponent in addressComponents {
        guard let types = addressComponent["types"] as? [String],
              types.first == "postal_town",
              let name = addressComponent["long_name"] as? String else {
          continue
        }
        postalTown = name
        break
      }
    }
    self.postalTown = postalTown
    super.init(dictionary: dictionary)
  }
}
