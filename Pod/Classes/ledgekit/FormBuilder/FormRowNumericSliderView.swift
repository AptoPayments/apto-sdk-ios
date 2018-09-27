//
//  FormNumericSliderView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 31/01/16.
//
//

import UIKit
import Bond
import SnapKit

open class FormRowNumericSliderView: FormRowView, RangeSliderDelegate {
  // MARK: - Public attributes
  var numberValidator: DataValidator<Int>? {
    didSet {
      if !self.swipping {
        self.validateInt(self.numberValidator, number: self.value)
      }
      else {
        self.valid.next(false)
      }
    }
  }

  var value: Int? {
    didSet {
      if self.value == nil {
        self.value = 0
      }
      self.updateTextWith(value: self.value)
      if !self.swipping {
        self.validateInt(self.numberValidator, number: self.value)
      }
      else {
        self.valid.next(false)
      }
    }
  }

  var minStep: Int {
    didSet {
      self.slider.minStep = self.minStep
    }
  }

  var maximumValue: Int {
    get {
      return self.slider.maximumValue
    }
    set {
      self.slider.maximumValue = newValue - (newValue % self.minStep)
      self.value = min(self.value!, newValue - (newValue % self.minStep)) // swiftlint:disable:this force_unwrapping
    }
  }

  var setupComplete: Bool = false {
    didSet {
      self.slider.initialValueSetup = setupComplete
    }
  }

  var trackHighlightTintColor: UIColor {
    didSet {
      self.slider.trackHighlightTintColor = self.trackHighlightTintColor
    }
  }

  var trackTintColor: UIColor {
    didSet {
      self.slider.trackTintColor = self.trackTintColor
    }
  }

  init(valueLabel: UILabel,
       minimumValue: Int,
       maximumValue: Int,
       textPattern: String? = nil,
       validator: DataValidator<Int>? = nil,
       accessibilityLabel: String? = nil,
       uiConfig: ShiftUIConfig) {
    let slider = RangeSlider(frame: CGRect(x: 0, y: 0, width: 280, height: 30))
    slider.maximumValue = maximumValue
    slider.minimumValue = minimumValue
    self.slider = slider
    self.valueLabel = valueLabel
    self.textPattern = textPattern
    self.minStep = 0
    self.trackHighlightTintColor = uiConfig.uiPrimaryColor
    self.trackTintColor = uiConfig.formSliderTrackColor
    super.init(showSplitter: false)
    if let accessibilityLabel = accessibilityLabel {
      self.accessibilityLabel = accessibilityLabel
      self.isAccessibilityElement = true
    }
    setUpValueLabel(valueLabel: valueLabel)
    setUpSlider(slider: slider)
    self.value = 0

    self.numberValidator = validator
    self.validateInt(self.numberValidator, number: self.value)
  }

  private func setUpValueLabel(valueLabel: UILabel) {
    self.contentView.addSubview(valueLabel)
    self.valueLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.contentView)
      make.top.equalTo(self.contentView)
    }
  }

  private func setUpSlider(slider: RangeSlider) {
    self.slider.trackHighlightTintColor = self.trackHighlightTintColor
    self.slider.trackTintColor = self.trackTintColor
    slider.delegate = self
    self.contentView.addSubview(self.slider)
    self.slider.snp.makeConstraints { make in
      make.left.right.equalTo(self.contentView)
      make.top.equalTo(self.valueLabel.snp.bottom).offset(16)
      make.height.equalTo(30)
      make.bottom.equalTo(self.contentView).offset(-15)
    }
    self.slider.updateLayerFrames()
    self.slider.addTarget(self, action: #selector(FormRowNumericSliderView.sliderChange), for: .valueChanged)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Binding Extensions
  private var _bndNumber: Observable<Int?>?
  public var bndNumber: Observable<Int?> {
    if let bndNumber = _bndNumber {
      return bndNumber
    }
    else {
      let bndNumber = Observable<Int?>(self.value)
      _ = bndNumber.observeNext { [weak self] (value: Int?) in
        self?.value = value
        guard let value = value else {
          self?.slider.currentValue = 0
          return
        }
        self?.slider.currentValue = value
      }
      _bndNumber = bndNumber
      return bndNumber
    }
  }

  @objc func sliderChange() {
    self.bndNumber.value = self.slider.currentValue
  }

  override open func updateConstraints() {
    super.updateConstraints()
    self.slider.updateLayerFrames()
  }

  // MARK: - Private methods and attributes

  fileprivate let slider: RangeSlider
  fileprivate let valueLabel: UILabel
  fileprivate let textPattern: String?

  fileprivate func updateTextWith(value: Int?) {
    guard let value = value else {
      self.valueLabel.text = ""
      return
    }
    guard let textPattern = self.textPattern else {
      self.valueLabel.text = String(Int(value))
      return
    }
    self.valueLabel.text = String(format: textPattern, arguments: [Int(value)])
  }

  // MARK: - RangeSliderDelegate

  private var swipping = false

  func didStartSwippingIn(rangeSlider: RangeSlider) {
    self.valid.next(false)
    swipping = true
  }

  func didFinishSwippingIn(rangeSlider: RangeSlider) {
    swipping = false
    self.validateInt(self.numberValidator, number: self.value)
  }
}

class MinValueDoubleValidator: DataValidator<Double> {
  init(minValue: Double, failReasonMessage: String) {
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
