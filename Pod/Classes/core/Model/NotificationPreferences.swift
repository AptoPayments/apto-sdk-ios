//
// NotificationPreferences.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 06/03/2019.
//

import SwiftyJSON

public class NotificationGroup {
  public enum Category: String {
    case cardActivity = "card_activity"
    case cardStatus = "card_status"
    case legal = "legal"

    public var title: String {
      switch self {
      case .cardActivity: return "notification_preferences.card_activity.title".podLocalized()
      case .cardStatus: return "notification_preferences.card_status.title".podLocalized()
      case .legal: return "notification_preferences.legal.title".podLocalized()
      }
    }

    public var description: String {
      switch self {
      case .cardActivity: return "notification_preferences.card_activity.description".podLocalized()
      case .cardStatus: return "notification_preferences.card_status.description".podLocalized()
      case .legal: return "notification_preferences.legal.description".podLocalized()
      }
    }

    init?(string: String?) {
      guard let string = string, let value = Category(rawValue: string) else {
        return nil
      }
      self = value
    }
  }

  public enum GroupId: String {
    case paymentSuccessful = "payment_successful"
    case paymentDeclined = "payment_declined"
    case atmWithdrawal = "atm_withdrawal"
    case incomingTransfer = "incoming_transfer"
    case cardStatus = "card_status"
    case legal = "legal"

    public var description: String {
      switch self {
      case .paymentSuccessful: return "notification_preferences.card_activity.payment_successful.title".podLocalized()
      case .paymentDeclined: return "notification_preferences.card_activity.payment_declined.title".podLocalized()
      case .atmWithdrawal: return "notification_preferences.card_activity.atm_withdrawal.title".podLocalized()
      case .incomingTransfer: return "notification_preferences.card_activity.incoming_transfer.title".podLocalized()
      case .cardStatus: return ""
      case .legal: return ""
      }
    }

    init?(string: String?) {
      guard let string = string, let value = GroupId(rawValue: string) else {
        return nil
      }
      self = value
    }
  }

  public enum State: String {
    case enabled
    case disabled

    init?(string: String?) {
      guard let string = string, let value = State(rawValue: string) else {
        return nil
      }
      self = value
    }
  }

  public class Channel {
    public var push: Bool?
    public var email: Bool?
    public var sms: Bool?

    public init(push: Bool? = nil, email: Bool? = nil, sms: Bool? = nil) {
      self.push = push
      self.email = email
      self.sms = sms
    }
  }

  public let groupId: NotificationGroup.GroupId
  public let category: NotificationGroup.Category
  public let state: NotificationGroup.State
  public let channel: NotificationGroup.Channel

  public init(groupId: NotificationGroup.GroupId, category: NotificationGroup.Category, state: NotificationGroup.State,
              channel: NotificationGroup.Channel) {
    self.groupId = groupId
    self.category = category
    self.state = state
    self.channel = channel
  }
}

public class NotificationPreferences {
  public let preferences: [NotificationGroup]

  public init(preferences: [NotificationGroup]) {
    self.preferences = preferences
  }
}

extension JSON {
  var notificationPreferences: NotificationPreferences? {
    guard let preferences = self["preferences"].linkObject as? [NotificationGroup?] else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse notification preferences \(self)"))
      return nil
    }
    let compacted = preferences.compactMap { return $0 }
    return NotificationPreferences(preferences: compacted)
  }

  var notificationGroup: NotificationGroup? {
    guard let category = NotificationGroup.Category(string: self["category_id"].string),
          let type = NotificationGroup.GroupId(string: self["group_id"].string),
          let state = NotificationGroup.State(string: self["state"].string) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse notification group \(self)"))
      return nil
    }
    return NotificationGroup(groupId: type,
                             category: category,
                             state: state,
                             channel: self["active_channels"].notificationGroupChannel)
  }

  var notificationGroupChannel: NotificationGroup.Channel {
    let push = self["push"].bool
    let email = self["email"].bool
    let sms = self["sms"].bool
    return NotificationGroup.Channel(push: push, email: email, sms: sms)
  }
}

extension NotificationPreferences {
  func jsonSerialize() -> [String: AnyObject] {
    let groups = preferences.map { return $0.jsonSerialize() }
    return ["preferences": groups as AnyObject]
  }
}

extension NotificationGroup {
  func jsonSerialize() -> [String: AnyObject] {
    var data = [String: AnyObject]()
    data["group_id"] = groupId.rawValue as AnyObject
    data["active_channels"] = channel.jsonSerialize()  as AnyObject
    return data
  }
}

extension NotificationGroup.Channel {
  func jsonSerialize() -> [String: AnyObject] {
    var data = [String: AnyObject]()
    if let push = self.push {
      data["push"] = push as AnyObject
    }
    if let email = self.email {
      data["email"] = email as AnyObject
    }
    if let sms = self.sms {
      data["sms"] = sms as AnyObject
    }
    return data
  }
}
