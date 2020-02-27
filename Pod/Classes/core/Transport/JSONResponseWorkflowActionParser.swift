//
//  JSONResponseWorkflowActionParser.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 23/10/2017.
//
//

import Foundation
import SwiftyJSON

extension JSON {
  var workflowAction: WorkflowAction? {
    guard let actionType = WorkflowActionType.from(typeName: self["action_type"].string) else {
      return nil
    }
    let actionId = self["action_id"].string
    let name = self["name"].string
    let order = self["order"].int
    let status = WorkflowActionStatus.from(typeValue: self["status"].int)
    let configuration = self["configuration"].linkObject as? WorkflowActionConfiguration

    // Read the copies
    if let copies = self["labels"].dictionaryObject as? [String: String] {
      StringLocalizationStorage.shared.append(copies)
    }

    return WorkflowAction(actionId: actionId,
                          name: name,
                          order: order,
                          status: status,
                          actionType: actionType,
                          configuration: configuration)
  }

  var showGenericMessageWorkflowActionConfiguration: ShowGenericMessageActionConfiguration? {
    guard let title = self["title"].string, let content = self["content"].linkObject as? Content else {
      return nil
    }
    let image = self["image"].string
    let trackerEventName = self["tracker_event_name"].string
    let trackerIncrementName = self["tracker_increment_name"].string
    let callToAction = self["call_to_action"].linkObject as? CallToAction
    return ShowGenericMessageActionConfiguration(title: title,
                                                 content: content,
                                                 image: image,
                                                 trackerEventName: trackerEventName,
                                                 trackerIncrementName: trackerIncrementName,
                                                 callToAction: callToAction)
  }

  var callToAction: CallToAction? {
    guard
      let title = self["title"].string,
      let rawCallToActionType = self["action_type"].string,
      let callToActionType = CallToActionType(rawValue: rawCallToActionType) else {
        return nil
    }
    let externalUrl = self["external_url"].string
    let trackerClickEventName = self["tracker_click_event_name"].string
    let trackerClickIncrementName = self["tracker_increment_name"].string
    return CallToAction(title: title,
                        callToActionType: callToActionType,
                        externalUrl: externalUrl,
                        trackerClickEventName: trackerClickEventName,
                        trackerClickIncrementName: trackerClickIncrementName)
  }

  var collectUserDataActionConfiguration: CollectUserDataActionConfiguration? {
    let dataPointGroup = self["required_datapoint_groups"]
    guard
      let page = dataPointGroup["page"].int,
      let rows = dataPointGroup["rows"].int,
      let totalCount = dataPointGroup["total_count"].int,
      let type = dataPointGroup["type"].string,
      let hasMore = dataPointGroup["has_more"].bool else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse collect user data action \(self)"))
        return nil
    }

    let requiredDataPointsList = RequiredDataPointList()
    if let dataPointFields = dataPointGroup["data"].array {
      dataPointFields.compactMap {
        guard let array = $0["datapoints"]["data"].array else {
          return nil
        }
        return array.compactMap {
          return $0.requiredDatapoint
        }
      }.reduce([], +).forEach {
        requiredDataPointsList.add(requiredDataPoint: $0)
      }
    }

    return CollectUserDataActionConfiguration(page: page,
                                              rows: rows,
                                              totalCount: totalCount,
                                              type: type,
                                              hasMore: hasMore,
                                              requiredDataPointsList: requiredDataPointsList)
  }

  var disclaimerActionConfiguration: Content? {
    return self["disclaimer"].content
  }

  var selectBalanceStoreActionConfiguration: SelectBalanceStoreActionConfiguration? {
    guard let allowedBalanceTypes = self["allowed_balance_types"].linkObject as? [AllowedBalanceType] else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't select balance store action \(self)"))
      return nil
    }
    let assetUrl: URL?
    if let string = self["action_asset"].string, let url = URL(string: string) {
      assetUrl = url
    }
    else {
      assetUrl = nil
    }
    return SelectBalanceStoreActionConfiguration(allowedBalanceTypes: allowedBalanceTypes, assetUrl: assetUrl)
  }

  var issueCardActionConfiguration: IssueCardActionConfiguration? {
    let legalNotice = self["legal_notice"].content
    let errorAsset = self["error_asset"].string
    return IssueCardActionConfiguration(legalNotice: legalNotice, errorAsset: errorAsset)
  }

  var waitListActionConfiguration: WaitListActionConfiguration {
    let asset = self["asset"].string
    let backgroundImage = self["background_image"].string
    let backgroundColor = self["background_color"].string
    let darkBackgroundColor = self["dark_background_color"].string
    return WaitListActionConfiguration(asset: asset, backgroundImage: backgroundImage, backgroundColor: backgroundColor,
                                       darkBackgroundColor: darkBackgroundColor)
  }
}
