//
//  ActionConfirmerFake.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 16/10/2018.
//
//

@testable import ShiftSDK

enum ActionConfirmerAction {
  case ok
  case cancel
}

class ActionConfirmerFake: ActionConfirmer {
  static var nextActionToExecute: ActionConfirmerAction?
  static private(set) var confirmCalled = false
  static private(set) var lastTitle: String?
  static private(set) var lastMessage: String?
  static private(set) var lastOkTitle: String?
  static private(set) var lastCancelTitle: String?
  static func confirm(title: String?,
                      message: String?,
                      okTitle: String,
                      cancelTitle: String?,
                      handler: @escaping (UIAlertAction) -> Void) {
    confirmCalled = true
    lastTitle = title
    lastMessage = message
    lastOkTitle = okTitle
    lastCancelTitle = cancelTitle

    if let action = nextActionToExecute {
      switch action {
      case .ok:
        handler(UIAlertAction(title: okTitle, style: .default))
      case .cancel:
        handler(UIAlertAction(title: cancelTitle, style: .cancel))
      }
    }
  }
}
