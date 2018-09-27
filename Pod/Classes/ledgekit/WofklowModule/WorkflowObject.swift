//
//  WorkflowObject.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/11/2017.
//

import UIKit

protocol WorkflowObject {
  var workflowObjectId: String { get }
  var nextAction: WorkflowAction { get }
}

protocol WorkflowObjectStatusRequester {
  func getStatusOf(workflowObject: WorkflowObject, completion: @escaping (Result<WorkflowObject,NSError>.Callback))
}
