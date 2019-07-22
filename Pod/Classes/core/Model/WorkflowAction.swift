//
//  WorkflowAction.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 20/10/2017.
//
//

import UIKit

public enum WorkflowActionStatus {
  case enabled
  case disabled
  static func from(typeValue: Int?) -> WorkflowActionStatus? {
    if typeValue == 1 { return .enabled }
    else if typeValue == 0 { return .disabled }
    return nil
  }
}

public enum WorkflowActionType: String {
  case notSupportedActionType
  case showGenericMessage = "show_generic_message"
  case collectUserData = "collect_user_data"
  case selectBalanceStore = "select_balance_store"
  case issueCard = "issue_card"
  case showDisclaimer = "show_disclaimer"
  case verifyIDDocument = "verify_id_document"
  case waitList = "show_waitlist"

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

public protocol WorkflowActionConfiguration {
}

public class WorkflowAction: NSObject {
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

public struct CollectUserDataActionConfiguration: WorkflowActionConfiguration {
  let page: Int
  let rows: Int
  let totalCount: Int
  let type: String
  let hasMore: Bool
  public let requiredDataPointsList: RequiredDataPointList
}

extension Content: WorkflowActionConfiguration {
}

public class ShowGenericMessageActionConfiguration: WorkflowActionConfiguration {
  public let title: String
  public let content: Content
  public let image: String?
  public let trackerEventName: String?
  public let trackerIncrementName: String?
  public let callToAction: CallToAction?

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

public struct SelectBalanceStoreActionConfiguration: WorkflowActionConfiguration {
  public let allowedBalanceTypes: [AllowedBalanceType]
}

public struct IssueCardActionConfiguration: WorkflowActionConfiguration {
  public let legalNotice: Content?
  public let errorAsset: String?
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

public struct WaitListActionConfiguration: WorkflowActionConfiguration {
  public let asset: String?
  public let backgroundImage: String?
  public let backgroundColor: String?

  public init(asset: String?, backgroundImage: String?, backgroundColor: String?) {
    self.asset = asset
    self.backgroundImage = backgroundImage
    self.backgroundColor = backgroundColor
  }
}
