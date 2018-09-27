//
//  Project.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 30/10/2017.
//
//

import UIKit

@objc open class Project: NSObject {
  public var team: Team?
  public let projectId: String
  let name: String
  
  public init(team: Team?, projectId: String, name: String) {
    self.team = team
    self.projectId = projectId
    self.name = name
  }
  
}
