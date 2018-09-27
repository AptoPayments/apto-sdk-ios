//
//  RangeSlider.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 03/02/16.
//
//

import UIKit

protocol RangeSliderDelegate: class {
  func didStartSwippingIn(rangeSlider: RangeSlider)
  func didFinishSwippingIn(rangeSlider: RangeSlider)
}

class RangeSliderTrackLayer: CALayer {
  weak var rangeSlider: RangeSlider?

  override func draw(in ctx: CGContext) {
    if let slider = rangeSlider {
      let sliderPosition = slider.currentlocation.x

      // Left clip
      let cornerRadius = bounds.height * slider.curvaceousness / 2.0
      let path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                  y: 0,
                                                  width: sliderPosition,
                                                  height: bounds.height),
                              cornerRadius: cornerRadius)
      ctx.addPath(path.cgPath)

      // Fill the hilighted range
      ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
      ctx.addPath(path.cgPath)
      ctx.fillPath()

      // Right clip
      let upperValuePosition = bounds.width
      let path2 = UIBezierPath(roundedRect: CGRect(x: sliderPosition,
                                                   y: 0,
                                                   width: upperValuePosition - sliderPosition,
                                                   height: bounds.height),
                               cornerRadius: cornerRadius)
      ctx.setFillColor(slider.trackTintColor.cgColor)
      ctx.addPath(path2.cgPath)
      ctx.fillPath()
    }
  }
}

class RangeSliderThumbLayer: CALayer {
  var highlighted: Bool = false {
    didSet {
      setNeedsDisplay()
    }
  }
  weak var rangeSlider: RangeSlider?

  override func draw(in ctx: CGContext) {
    if let slider = rangeSlider {
      let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
      let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
      let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)

      // Fill
      ctx.setFillColor(slider.thumbTintColor.cgColor)
      ctx.addPath(thumbPath.cgPath)
      ctx.fillPath()

      // Outline
      let strokeColor = UIColor.lightGray
      ctx.setStrokeColor(strokeColor.cgColor)
      ctx.setLineWidth(0.2)
      ctx.addPath(thumbPath.cgPath)
      ctx.strokePath()

      if highlighted {
        ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
        ctx.addPath(thumbPath.cgPath)
        ctx.fillPath()
      }
    }
  }
}

@IBDesignable
public class RangeSlider: UIControl {
  weak var delegate: RangeSliderDelegate?
  var initialValueSetup = false
  @IBInspectable var minimumValue: Int = 0 {
    willSet(newValue) {
      assert(newValue < maximumValue, "range-slider.warning.minimum-lower-than-maximum".podLocalized())
    }
    didSet {
      if minimumValue > currentValue {
        currentValue = minimumValue
      }
      currentlocation.x = positionForValue(currentValue)
      updateLayerFrames()
    }
  }

  @IBInspectable var maximumValue: Int = 0 {
    willSet(newValue) {
      assert(newValue > minimumValue, "range-slider.warning.maximumValue-greater-than-minimum".podLocalized())
    }
    didSet {
      if maximumValue < currentValue {
        currentValue = maximumValue
      }
      currentlocation.x = positionForValue(currentValue)
      updateLayerFrames()
    }
  }

  @IBInspectable var currentValue: Int = 0 {
    didSet {
      if currentValue < minimumValue {
        currentValue = minimumValue
      }
      if currentValue > maximumValue {
        currentValue = maximumValue
      }
      if !initialValueSetup {
        currentlocation.x = positionForValue(currentValue)
      }
      updateLayerFrames()
    }
  }

  @IBInspectable var minStep: Int = 0

  @IBInspectable var trackTintColor: UIColor = colorize(0xEBEBEB) {
    didSet {
      trackLayer.setNeedsDisplay()
    }
  }

  @IBInspectable var trackHighlightTintColor: UIColor = colorize(0x0073F0) {
    didSet {
      trackLayer.setNeedsDisplay()
    }
  }

  @IBInspectable var thumbTintColor: UIColor = UIColor.white {
    didSet {
      lowerThumbLayer.setNeedsDisplay()
    }
  }

  @IBInspectable var curvaceousness: CGFloat = 1.0 {
    didSet {
      if curvaceousness < 0.0 {
        curvaceousness = 0.0
      }

      if curvaceousness > 1.0 {
        curvaceousness = 1.0
      }

      trackLayer.setNeedsDisplay()
      lowerThumbLayer.setNeedsDisplay()
    }
  }

  fileprivate var currentlocation = CGPoint()
  fileprivate var maximumPosition: CGFloat = 0
  fileprivate var minimumPosition: CGFloat = 0

  fileprivate let trackLayer = RangeSliderTrackLayer()
  fileprivate let lowerThumbLayer = RangeSliderThumbLayer()

  fileprivate var thumbWidth: CGFloat {
    return CGFloat(bounds.height)
  }

  override public var frame: CGRect {
    didSet {
      self.maximumPosition = self.positionForValue(maximumValue)
      self.minimumPosition = self.positionForValue(minimumValue)
      updateLayerFrames()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeLayers()
  }

  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    initializeLayers()
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    self.maximumPosition = self.positionForValue(self.maximumValue)
    self.minimumPosition = self.positionForValue(self.minimumValue)
    self.updateLayerFrames()
  }

  fileprivate func initializeLayers() {
    self.isAccessibilityElement = true
    trackLayer.rangeSlider = self
    trackLayer.contentsScale = UIScreen.main.scale
    layer.addSublayer(trackLayer)

    lowerThumbLayer.rangeSlider = self
    lowerThumbLayer.contentsScale = UIScreen.main.scale
    layer.addSublayer(lowerThumbLayer)
  }

  func updateLayerFrames() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)

    trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 2 - 1)
    trackLayer.setNeedsDisplay()

    let lowerThumbCenter = self.currentlocation.x
    lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0,
                                   y: 0.0,
                                   width: thumbWidth,
                                   height: thumbWidth)
    lowerThumbLayer.setNeedsDisplay()
    lowerThumbLayer.shadowOffset = CGSize(width: 0, height: 3)
    lowerThumbLayer.shadowRadius = 4
    lowerThumbLayer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.4).cgColor
    lowerThumbLayer.shadowOpacity = 1

    CATransaction.commit()
  }

  func positionForValue(_ value: Int) -> CGFloat {
    let dValue: Double = Double(value)
    let dMaximumValue: Double = Double(maximumValue)
    let dMinimumValue: Double = Double(minimumValue)
    return CGFloat(Double(bounds.width - thumbWidth) * (dValue - dMinimumValue) /
      (dMaximumValue - dMinimumValue) + Double(thumbWidth / 2.0))
  }

  func valueForPosition(_ position: CGFloat) -> Int {
    let start = maximumValue - minimumValue + Int(thumbWidth) / 2
    let end = Int(bounds.width - thumbWidth)
    let pos = start / end
    return minimumValue + Int(position) * pos
  }

  func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
    return min(max(value, lowerValue), upperValue)
  }

  // MARK: - Touches

  override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {

    // Hit test the thumb layers
    if lowerThumbLayer.frame.contains(touch.location(in: self)) {
      currentlocation = touch.location(in: self)
      lowerThumbLayer.highlighted = true
      self.delegate?.didStartSwippingIn(rangeSlider: self)
      return lowerThumbLayer.highlighted
    }
    else {
      let clickableArea = CGRect(x: trackLayer.frame.origin.x,
                                 y: trackLayer.frame.origin.y - 25,
                                 width: trackLayer.frame.size.width,
                                 height: trackLayer.frame.size.height + 50)
      if clickableArea.contains(touch.location(in: self)) {
        currentlocation = touch.location(in: self)
        updateValueForCurrentlocation()
        return true
      }
    }

    return false
  }

  override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    currentlocation = touch.location(in: self)
    updateValueForCurrentlocation()
    return true
  }

  override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    lowerThumbLayer.highlighted = false
    self.delegate?.didFinishSwippingIn(rangeSlider: self)
  }

  fileprivate func updateValueForCurrentlocation() {
    if currentlocation.x > self.maximumPosition {
      currentlocation.x = self.maximumPosition
    }
    if currentlocation.x < self.minimumPosition {
      currentlocation.x = self.minimumPosition
    }
    var newValue = self.valueForPosition(currentlocation.x - self.thumbWidth / 2)
    if self.minStep > 0 {
      newValue -= newValue % self.minStep
    }
    self.currentValue = newValue
    sendActions(for: .valueChanged)
  }
}
