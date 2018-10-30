//
//  UIAlertController.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 15/08/16.
//
//

import Foundation

public protocol ActionConfirmer {
  static func confirm(title: String?,
                      message: String?,
                      okTitle: String,
                      cancelTitle: String?,
                      handler: @escaping (UIAlertAction) -> Void)
}

public protocol AnswerPrompter {
  static func prompt(title: String?,
                     message: String?,
                     placeholder: String?,
                     keyboardType: UIKeyboardType,
                     okTitle: String,
                     cancelTitle: String?,
                     handler: @escaping (_ answer: String?) -> Void)
}

extension UIAlertController: ActionConfirmer {
  public func show(_ animated: Bool = true, addOkButton: Bool = false) {
    UIApplication.topViewController()?.present(self, animated: animated, completion: nil)
  }

  public static func okAction(_ title: String, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
    return UIAlertAction(title: title, style: .default, handler: handler)
  }

  public static func cancelAction(_ title: String, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
    return UIAlertAction(title: title, style: .cancel, handler: handler)
  }

  public static func showMenuInActionSheet(title: String? = nil,
                                           message: String? = nil,
                                           cancelButton: String,
                                           actions: [String],
                                           handler: @escaping (UIAlertAction) -> Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    for action in actions {
      alertController.addAction(UIAlertAction(title: action, style: .default, handler: handler))
    }
    alertController.addAction(UIAlertController.cancelAction(cancelButton))
    alertController.show()
  }

  public static func confirm(title: String? = nil,
                             message: String? = nil,
                             okTitle: String,
                             cancelTitle: String? = nil,
                             handler: @escaping (UIAlertAction) -> Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if let cancelTitle = cancelTitle {
      alertController.addAction(cancelAction(cancelTitle, handler: handler))
    }
    alertController.addAction(okAction(okTitle, handler: handler))
    alertController.show()
  }
}

extension UIAlertController: AnswerPrompter {
  static public func prompt(title: String?,
                            message: String?,
                            placeholder: String?,
                            keyboardType: UIKeyboardType,
                            okTitle: String,
                            cancelTitle: String?,
                            handler: @escaping (_ answer: String?) -> Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = placeholder
      textField.keyboardType = keyboardType
    }
    if let cancelTitle = cancelTitle {
      alertController.addAction(cancelAction(cancelTitle) { _ in
        handler(nil)
      })
    }
    alertController.addAction(okAction(okTitle) { [unowned alertController] _ in
      let textField = alertController.textFields![0] // swiftlint:disable:this force_unwrapping
      handler(textField.text)
    })
    alertController.show()
  }
}
