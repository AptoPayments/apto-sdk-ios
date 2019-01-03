//
//  MultiStepForm.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 30/01/16.
//
//

import SnapKit

enum MultiStepFormAnimation {
  case none
  case crossDissolve
  case pop
  case push
}

open class MultiStepForm: UIScrollView, ReturnButtonListenerProtocol, RowFocusListenerProtocol {
  override init(frame: CGRect) {
    self.contentView = UIView()
    super.init(frame: frame)
    self.addSubview(self.contentView)
    self.registerToKeyboardNotifications()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    self.unregisterFromKeyboardNotifications()
  }

  @discardableResult override open func resignFirstResponder() -> Bool {
    guard let focusedRow = self.focusedRow else {
      return true
    }
    return focusedRow.resignFirstResponder()
  }

  // MARK: - Public methods

  open func show(rows: [FormRowView]) {
    self.show(rows: rows, withAnimation: .none)
  }

  func show(rows: [FormRowView], withAnimation animation: MultiStepFormAnimation) {
    adjustWidthIfNecessary()

    for row in self.rows {
      self.animateRowExiting(row, animation: animation)
    }
    self.rows = rows

    var prevRow: UIView? = nil
    for row in self.rows {
      row.returnButtonListener = self
      row.rowFocusListener = self
      self.animateRowEntering(row, prevRow: prevRow, animation: animation)
      prevRow = row
    }

    // Last row bottom constraint
    prevRow?.snp.makeConstraints { make in
      make.bottom.equalTo(self.contentView)
    }
  }

  @discardableResult open override func becomeFirstResponder() -> Bool {
    for row in self.rows {
      if row.becomeFirstResponder() {
        row.focus()
        return true
      }
    }

    return false
  }

  // MARK: - ReturnButtonListenerProtocol

  func focusNextRowfrom(row: FormRowView) -> Bool {
    if let nextRow = nextRowForRow(row) {
      nextRow.becomeFirstResponder()
    }
    return false
  }

  func focusPreviousRowfrom(row: FormRowView) -> Bool {
    if let nextRow = previousRowForRow(row) {
      nextRow.becomeFirstResponder()
    }
    return false
  }

  // MARK: - RowFocusListenerProtocol

  var focusedRow: FormRowView?

  func rowDidBeginEditing(_ row: FormRowView) {
    self.focusedRow = row
  }

  func rowDidEndEditing(_ row: FormRowView) {
    self.focusedRow = nil
  }

  // MARK: - Private Attributes

  let contentView: UIView
  var rows: [FormRowView] = []
  var adjustedWidth = false

  // MARK: - Private Methods

  private func animateRowEntering(_ row: UIView, prevRow: UIView?, animation: MultiStepFormAnimation) {
    let topConstraint: ConstraintItem
    if let prevRow = prevRow {
      topConstraint = prevRow.snp.bottom
    }
    else {
      topConstraint = contentView.snp.top
    }
    switch animation {
    case .none:
      self.contentView.addSubview(row)
      row.snp.makeConstraints { make in
        make.left.right.equalTo(self.contentView)
        make.top.equalTo(topConstraint)
      }
    case .crossDissolve:
      self.fadeIn(animations: {
        self.contentView.addSubview(row)
        row.snp.makeConstraints { make in
          make.left.right.equalTo(self.contentView)
          make.top.equalTo(topConstraint)
        }
      })
    case .pop:
      self.contentView.translate(x: -bounds.width) {
        self.contentView.addSubview(row)
        row.snp.makeConstraints { make in
          make.left.right.equalTo(self.contentView)
          make.top.equalTo(topConstraint)
        }
      }
    case .push:
      self.contentView.translate(x: bounds.width) {
        self.contentView.addSubview(row)
        row.snp.makeConstraints { make in
          make.left.right.equalTo(self.contentView)
          make.top.equalTo(topConstraint)
        }
      }
    }
  }

  private func animateRowExiting(_ row: UIView, animation: MultiStepFormAnimation) {
    switch animation {
    case .none:
      row.removeFromSuperview()
    case .crossDissolve:
      self.fadeIn(animations: {
        row.removeFromSuperview()
      })
    case .pop:
      self.contentView.translate(x: bounds.width) {
        row.removeFromSuperview()
      }
    case .push:
      self.contentView.translate(x: -bounds.width) {
        row.removeFromSuperview()
      }
    }
  }

  func nextRowForRow(_ row: FormRowView) -> FormRowView? {
    let allRows = rows
    guard let index = allRows.index(of: row) else { return nil }
    guard index < allRows.count - 1 else { return nil }
    return allRows[index + 1]
  }

  private func previousRowForRow(_ row: FormRowView) -> FormRowView? {
    let allRows = rows
    guard let index = allRows.index(of: row) else { return nil }
    guard index > 0 else { return nil }
    return allRows[index - 1]
  }

  private func adjustWidthIfNecessary() {
    guard adjustedWidth == false,
          let superview = self.superview else {
      return
    }
    self.contentView.snp.makeConstraints { make in
      make.left.top.right.bottom.equalTo(self)
      make.width.equalTo(superview.snp.width)
    }
    adjustedWidth = true
  }
}

extension MultiStepForm {
  private func registerToKeyboardNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(MultiStepForm.keyboardDidShow(_:)),
                                           name: NSNotification.Name.UIKeyboardDidShow,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(MultiStepForm.keyboardWillBeHidden(_:)),
                                           name: NSNotification.Name.UIKeyboardWillHide,
                                           object: nil)
  }

  private func unregisterFromKeyboardNotifications() {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }

  @objc public func keyboardDidShow(_ notification: Notification) {
    if let focusedRow = self.focusedRow,
       let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      let contentInsets = UIEdgeInsets(top: self.contentInset.top, left: 0.0, bottom: keyboardSize.height, right: 0.0)
      self.contentInset = contentInsets
      self.scrollIndicatorInsets = contentInsets
      var aRect = self.frame
      aRect.size.height -= keyboardSize.size.height
      if !aRect.contains(focusedRow.frame.origin) {
        self.scrollRectToVisible(focusedRow.frame, animated: true)
      }
    }
  }

  @objc public func keyboardWillBeHidden(_ notification: Notification) {
    let contentInsets = UIEdgeInsets(top: self.contentInset.top, left: 0.0, bottom: 0, right: 0.0)
    self.contentInset = contentInsets
    self.scrollIndicatorInsets = contentInsets
  }
}
