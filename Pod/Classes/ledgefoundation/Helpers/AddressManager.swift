//
//  AddressManager.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 02/02/16.
//
//

import Foundation
import GoogleKit

open class AddressManager {
  public static func defaultManager(apiKey: String? = nil) -> AddressManager {
    guard let sharedValidator = AddressManager.sharedValidator else {
      let addressManager = AddressManager(apiKey: apiKey)
      AddressManager.sharedValidator = addressManager
      return addressManager
    }
    return sharedValidator
  }

  init(apiKey: String?) {
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

  // MARK: - Private methods and attributes

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
