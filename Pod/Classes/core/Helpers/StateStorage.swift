//
//  StateStorage.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 04/02/16.
//
//

import Foundation

open class StateStorage {
    let states: [String: [State]]
    let isoCodeStates: [String: [String: State]]
    let nameStates: [String: [String: State]]

    init() {
        let usStates = StateStorage.usStates.compactMap { isoCode, name -> State in
            State(isoCode: isoCode, name: name)
        }
        states = ["US": usStates]
        var usIsoCodeStates = [String: State]()
        var usNameStates = [String: State]()
        for state in usStates {
            usIsoCodeStates[state.isoCode] = state
            usNameStates[state.name] = state
        }
        isoCodeStates = ["US": usIsoCodeStates]
        nameStates = ["US": usNameStates]
    }

    open func getStates(country: String) -> [State]? {
        guard let states = states[country] else {
            return nil
        }
        return states
    }

    open func getStateBy(_ country: String, isoCode: String) -> State? {
        guard let countryStates = isoCodeStates[country] else {
            return nil
        }
        return countryStates[isoCode]
    }

    open func getStateBy(_ country: String, name: String) -> State? {
        guard let countryStates = nameStates[country] else {
            return nil
        }
        return countryStates[name]
    }

    // swiftlint:disable:next line_length colon comma
    fileprivate static let usStates = ["AK": "Alaska", "AL": "Alabama", "AR": "Arkansas", "AS": "American Samoa", "AZ": "Arizona", "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DC": "District of Columbia", "DE": "Delaware", "FL": "Florida", "GA": "Georgia", "GU": "Guam", "HI": "Hawaii", "IA": "Iowa", "ID": "Idaho", "IL": "Illinois", "IN": "Indiana", "KS": "Kansas", "KY": "Kentucky", "LA": "Louisiana", "MA": "Massachusetts", "MD": "Maryland", "ME": "Maine", "MI": "Michigan", "MN": "Minnesota", "MO": "Missouri", "MS": "Mississippi", "MT": "Montana", "NC": "North Carolina", "ND": "North Dakota", "NE": "Nebraska", "NH": "New Hampshire", "NJ": "New Jersey", "NM": "New Mexico", "NV": "Nevada", "NY": "New York", "OH": "Ohio", "OK": "Oklahoma", "OR": "Oregon", "PA": "Pennsylvania", "PR": "Puerto Rico", "RI": "Rhode Island", "SC": "South Carolina", "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas", "UT": "Utah", "VA": "Virginia", "VI": "Virgin Islands", "VT": "Vermont", "WA": "Washington", "WI": "Wisconsin", "WV": "West Virginia", "WY": "Wyoming"]
}
