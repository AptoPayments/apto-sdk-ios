//
//  WorkflowObject.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/11/2017.
//

import UIKit

public protocol WorkflowObject {
    var workflowObjectId: String { get }
    var nextAction: WorkflowAction { get }
}

public protocol WorkflowObjectStatusRequester {
    func getStatusOf(workflowObject: WorkflowObject, completion: @escaping (Result<WorkflowObject, NSError>.Callback))
}
