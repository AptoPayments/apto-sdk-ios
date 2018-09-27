//
//  Team.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 30/10/2017.
//
//

import UIKit

@objc open class Team: NSObject {
  open var teamId: String
  open var name: String
  
  public init (teamId: String, name: String) {
    self.teamId = teamId
    self.name = name
  }
  
}
