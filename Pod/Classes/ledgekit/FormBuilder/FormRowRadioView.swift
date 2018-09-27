//
//  FormRowRadioView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 27/02/16.
//
//

import UIKit
import Bond

class FormRowRadioView: FormRowMultilineView {
  var selectedValue: Int? {
    didSet {
      self.hideCurrentTick()
      guard let selectedValue = self.selectedValue else {
        return
      }
      if let line = lines.first(where: { $0.tag == selectedValue }) {
        self.showTickIn(view: line)
      }
    }
  }

  private var selectedLine: UIView?
  var tickImageView: UIImageView?

  var numberValidator: DataValidator<Int>? {
    didSet {
      self.validateInt(self.numberValidator, number: self.selectedValue)
    }
  }

  init(labels: [UILabel],
       values: [Int],
       leftIcons: [UIImage?]? = [],
       onImage: UIImage?,
       flashColor: UIColor?) {
    super.init(showSplitter: false, flashColor: flashColor)
    var lines: [UIView] = []
    var lineIdx = 0
    for label in labels {
      let line = UIView()
      line.tag = values[lineIdx]
      line.addSubview(label)
      if let leftIcons = leftIcons, lineIdx < leftIcons.count && leftIcons[lineIdx] != nil {
        let iconImageView = UIImageView(image: leftIcons[lineIdx])
        iconImageView.contentMode = .scaleAspectFit
        line.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
          make.left.equalTo(line.snp.left).offset(20)
          make.top.bottom.equalTo(line).inset(6)
          make.width.equalTo(40)
        }
        label.snp.makeConstraints { make in
          make.left.equalTo(iconImageView.snp.right).offset(20)
          make.top.bottom.equalTo(line).inset(12)
          make.right.equalTo(line).offset(-50)
        }
      }
      else {
        label.snp.makeConstraints { make in
          make.left.equalTo(line.snp.left).offset(20)
          make.top.bottom.equalTo(line).inset(12)
          make.right.equalTo(line).offset(-50)
        }
      }
      line.accessibilityLabel = label.text
      lines.append(line)
      lineIdx += 1
    }
    self.add(lines: lines)
    if onImage != nil {
      self.tickImageView = UIImageView(image: onImage)
    }
    else {
      self.tickImageView = UIImageView(image: UIImage.imageFromPodBundle("activation_check_blue.png")?.asTemplate())
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func lineTapped(_ gestureRecognizer: UIGestureRecognizer) {
    guard let view = gestureRecognizer.view else {
      return
    }
    if self.flashColor != nil {
      let backgroundColor = view.backgroundColor
      view.alpha = 0.5
      view.backgroundColor = self.flashColor
      UIView.animate(withDuration: 0.1) {
        view.backgroundColor = backgroundColor
        view.alpha = 1
      }
    }
    self.bndValue.next(view.tag)
  }

  // MARK: - Binding Extensions
  private var _bndValue: Observable<Int?>?
  var bndValue: Observable<Int?> {
    if let bndValue = _bndValue {
      return bndValue
    }
    else {
      let bndValue = Observable<Int?>(self.selectedValue)
      _ = bndValue.observeNext { [weak self] (value: Int?) in
        self?.selectedValue = value
        self?.validateInt(self?.numberValidator, number: self?.selectedValue)
      }
      _bndValue = bndValue
      return bndValue
    }
  }

  // MARK: - Private methods and attributes

  fileprivate func hideCurrentTick() {
    self.selectedLine = nil
    guard let tickImageView = self.tickImageView else {
      return
    }
    tickImageView.removeFromSuperview()
  }

  fileprivate func showTickIn(view: UIView) {
    self.selectedLine = view
    guard let tickImageView = self.tickImageView else {
      return
    }
    view.addSubview(tickImageView)
    tickImageView.snp.remakeConstraints { make in
      make.centerY.equalTo(view)
      make.right.equalTo(view).offset(-20)
    }
    tickImageView.alpha = 0
    UIView.animate(withDuration: 0.1) {
        tickImageView.alpha = 1
    }
  }
}

class MinValueIntValidator: DataValidator<Int> {
  init(minValue: Int, failReasonMessage: String) {
    super.init(failReasonMessage: failReasonMessage) { value -> ValidationResult in
      guard let value = value else {
        return .fail(reason: failReasonMessage)
      }
      if value > minValue {
        return .pass
      }
      else {
        return .fail(reason: failReasonMessage)
      }
    }
  }
}

class NonNullIntValidator: DataValidator<Int> {
  init(failReasonMessage: String) {
    super.init(failReasonMessage: failReasonMessage) { value -> ValidationResult in
      guard value != nil else {
        return .fail(reason: failReasonMessage)
      }
      return .pass
    }
  }
}
