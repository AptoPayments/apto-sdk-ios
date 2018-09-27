//
//  DataCollectorStepSpec.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 02/02/16.
//
//

import Foundation
import Bond
import ReactiveKit
import TTTAttributedLabel

protocol DataCollectorStepProtocol {
  var title: String { get }
  var rows: [FormRowView] { get }
  var validatableRows: [FormRowView] { get set }
  var valid: Observable<Bool> { get }
}

open class DataCollectorBaseStep {
  private let disposeBag = DisposeBag()
  var uiConfig: ShiftUIConfig
  var rows: [FormRowView] = []
  var validatableRows: [FormRowView] = []

  // Observable flag indicating that this row has passed validation
  public let valid = Observable(false)

  init(uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
    self.rows = self.setupRows()
    self.setupStepValidation()
  }

  func setupRows() -> [FormRowView] {
    return []
  }

  // swiftlint:disable identifier_name
  func setupStepValidation() {
    // The default implementation combines all the form rows valid flag added to this step
    // The bond library doesn't support a more generic approach to combine the values, so an
    // ugly (but functional) method is used here:
    if validatableRows.isEmpty {
      self.valid.next(true)
    }
    else {
      let signals = validatableRows.map {
        return $0.valid.toSignal()
      }
      combineLatest(signals) { (arrayOfBool: [Bool]) in
        arrayOfBool.reduce(true, { $0 && $1 })
      }.bind(to: self.valid).dispose(in: disposeBag)
    }
  }
  // swiftlint:enable identifier_name

  func stepSubtitleRowWith(text: String, height: CGFloat = 44) -> FormRowLabelView {
    return FormBuilder.screenSubtitleRowWith(text: text, uiConfig: uiConfig, height: height)
  }
}
