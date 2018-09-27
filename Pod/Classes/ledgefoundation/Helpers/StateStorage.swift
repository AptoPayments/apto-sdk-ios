//
//  StateStorage.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/02/16.
//
//

import Foundation

open class StateStorage {

  let states: [String:[State]]
  let isoCodeStates: [String:[String:State]]
  let nameStates: [String:[String:State]]
  
  init() {
    let usStates = StateStorage.usStates.compactMap { (isoCode:String, name:String) -> State in
      return State(isoCode:isoCode, name:name)
    }
    self.states = ["US":usStates]
    var usIsoCodeStates = [String:State]()
    var usNameStates = [String:State]()
    for state in usStates {
      usIsoCodeStates[state.isoCode] = state
      usNameStates[state.name] = state
    }
    self.isoCodeStates = ["US":usIsoCodeStates]
    self.nameStates = ["US":usNameStates]
  }
  
  open func getStates(country:String) -> [State]? {
    guard let states = self.states[country] else {
      return nil
    }
    return states
  }
  
  open func getStateBy(_ country:String, isoCode:String) -> State? {
    guard let countryStates = self.isoCodeStates[country] else {
      return nil
    }
    return countryStates[isoCode]
  }
  
  open func getStateBy(_ country:String, name:String) -> State? {
    guard let countryStates = self.nameStates[country] else {
      return nil
    }
    return countryStates[name]
  }

  static fileprivate let usStates = ["AK":"Alaska","AL":"Alabama","AR":"Arkansas","AS":"American Samoa","AZ":"Arizona","CA":"California","CO":"Colorado","CT":"Connecticut","DC":"District of Columbia","DE":"Delaware","FL":"Florida","GA":"Georgia","GU":"Guam","HI":"Hawaii","IA":"Iowa","ID":"Idaho","IL":"Illinois","IN":"Indiana","KS":"Kansas","KY":"Kentucky","LA":"Louisiana","MA":"Massachusetts","MD":"Maryland","ME":"Maine","MI":"Michigan","MN":"Minnesota","MO":"Missouri","MS":"Mississippi","MT":"Montana","NC":"North Carolina","ND":"North Dakota","NE":"Nebraska","NH":"New Hampshire","NJ":"New Jersey","NM":"New Mexico","NV":"Nevada","NY":"New York","OH":"Ohio","OK":"Oklahoma","OR":"Oregon","PA":"Pennsylvania","PR":"Puerto Rico","RI":"Rhode Island","SC":"South Carolina","SD":"South Dakota","TN":"Tennessee","TX":"Texas","UT":"Utah","VA":"Virginia","VI":"Virgin Islands","VT":"Vermont","WA":"Washington","WI":"Wisconsin","WV":"West Virginia","WY":"Wyoming"]
  
}
