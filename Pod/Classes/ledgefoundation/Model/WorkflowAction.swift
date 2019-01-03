//
//  WorkflowAction.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 20/10/2017.
//
//

import UIKit

enum WorkflowActionStatus {
  case enabled
  case disabled
  static func from(typeValue: Int?) -> WorkflowActionStatus? {
    if typeValue == 1 { return .enabled }
    else if typeValue == 0 { return .disabled }
    return nil
  }
}

enum WorkflowActionType: String {
  case notSupportedActionType
  case showGenericMessage = "show_generic_message"
  case selectFundingAccount = "select_funding_account"
  case collectUserData = "collect_user_data"
  case selectBalanceStore = "select_balance_store"
  case issueCard = "issue_card"
  case showDisclaimer = "show_disclaimer"
  case verifyIDDocument = "verify_id_document"

  static func from(typeName: String?) -> WorkflowActionType? {
    guard let typeName = typeName else {
      return .notSupportedActionType
    }

    if let value = self.init(rawValue: typeName) {
      return value
    }
    return .notSupportedActionType
  }
}

public enum CallToActionType: String {
  case continueFlow = "continue"
  case openExternalUrl = "open_external_url"
}

protocol WorkflowActionConfiguration {
  var presentationMode: UIViewControllerPresentationMode { get }
}

extension WorkflowActionConfiguration {
  var presentationMode: UIViewControllerPresentationMode {
    return .push
  }
}

class WorkflowAction: NSObject {
  open var actionId: String?
  open var name: String?
  open var order: Int?
  open var status: WorkflowActionStatus?
  open var actionType: WorkflowActionType
  open var configuration: WorkflowActionConfiguration?

  init(actionId: String?,
       name: String?,
       order: Int?,
       status: WorkflowActionStatus?,
       actionType: WorkflowActionType,
       configuration: WorkflowActionConfiguration?) {
    self.actionId = actionId
    self.name = name
    self.order = order
    self.status = status
    self.actionType = actionType
    self.configuration = configuration
  }
}

struct CollectUserDataActionConfiguration: WorkflowActionConfiguration {
  let page: Int
  let rows: Int
  let totalCount: Int
  let type: String
  let hasMore: Bool
  let requiredDataPointsList: RequiredDataPointList
}

extension Content: WorkflowActionConfiguration {
  var presentationMode: UIViewControllerPresentationMode {
    return .modal
  }
}

class ShowGenericMessageActionConfiguration: WorkflowActionConfiguration {
  var title: String
  var content: Content
  var image: String?
  var trackerEventName: String?
  var trackerIncrementName: String?
  var callToAction: CallToAction?

  init(title: String,
       content: Content,
       image: String?,
       trackerEventName: String?,
       trackerIncrementName: String?,
       callToAction: CallToAction?) {
    self.title = title
    self.content = content
    self.image = image
    self.trackerEventName = trackerEventName
    self.trackerIncrementName = trackerIncrementName
    self.callToAction = callToAction
  }
}

struct SelectBalanceStoreActionConfiguration: WorkflowActionConfiguration {
  let allowedBalanceTypes: [AllowedBalanceType]
}

struct IssueCardActionConfiguration: WorkflowActionConfiguration {
  let legalNotice: Content
}

open class CallToAction: NSObject {
  open var title: String
  open var callToActionType: CallToActionType
  open var externalUrl: String?
  open var trackerClickEventName: String?
  open var trackerClickIncrementName: String?

  public init(title: String,
              callToActionType: CallToActionType,
              externalUrl: String? = nil,
              trackerClickEventName: String? = nil,
              trackerClickIncrementName: String? = nil) {
    self.title = title
    self.callToActionType = callToActionType
    self.externalUrl = externalUrl
    self.trackerClickEventName = trackerClickEventName
    self.trackerClickIncrementName = trackerClickIncrementName
  }
}
