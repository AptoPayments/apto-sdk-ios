//
//  FormRowBalanceRadioView.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

import SnapKit
import Bond

struct FormRowBalanceRadioViewValue {
  let title: String
  let amount: Amount
  let subtitle: String?
}

class FormRowBalanceRadioView: FormRowMultilineView {
  var selectedValue: Int? {
    didSet {
      hideCurrentTick()
      guard let selectedValue = self.selectedValue else {
        return
      }
      if let line = lines.first(where: { $0.tag == selectedValue }) {
        showTickIn(view: line)
      }
    }
  }
  let tickImageView: UIImageView

  private var selectedLine: UIView?
  private let uiConfig: ShiftUIConfig

  init(items: [FormRowBalanceRadioViewValue], values: [Int], flashColor: UIColor?, uiConfig: ShiftUIConfig) {
    self.tickImageView = UIImageView(image: UIImage.imageFromPodBundle("activation_check_blue.png")?.asTemplate())
    self.uiConfig = uiConfig
    super.init(showSplitter: false, flashColor: flashColor)
    setUpRows(items: items, values: values)
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
      }
      _bndValue = bndValue
      return bndValue
    }
  }

  // MARK: - Private methods and attributes

  private func setUpRows(items: [FormRowBalanceRadioViewValue], values: [Int]) {
    var lines: [UIView] = []
    var lineIdx = 0
    for item in items {
      let line = UIView()
      line.tag = values[lineIdx]
      let row = createRowFor(item)
      line.addSubview(row)
      row.snp.makeConstraints { make in
        make.left.equalToSuperview().offset(40)
        make.top.bottom.equalToSuperview()
        make.right.equalToSuperview().inset(12)
      }
      line.accessibilityLabel = row.titleLabel.text
      lines.append(line)
      lineIdx += 1
    }
    add(lines: lines)
  }

  private func createRowFor(_ item: FormRowBalanceRadioViewValue) -> FormRowTitleSubtitleRightLabelView {
    let titleLabel = ComponentCatalog.mainItemLightLabelWith(text: item.title, uiConfig: uiConfig)
    let rightLabel = ComponentCatalog.amountMediumLabelWith(text: item.amount.text,
                                                            textAlignment: .right,
                                                            uiConfig: uiConfig)
    let subtitleLabel: UILabel?
    if let subtitle = item.subtitle {
      subtitleLabel = ComponentCatalog.itemDescriptionLabelWith(text: subtitle, uiConfig: uiConfig)
    }
    else {
      subtitleLabel = nil
    }
    return FormRowTitleSubtitleRightLabelView(titleLabel: titleLabel,
                                              subtitleLabel: subtitleLabel,
                                              rightLabel: rightLabel)
  }

  private func hideCurrentTick() {
    self.selectedLine = nil
    tickImageView.removeFromSuperview()
  }

  private func showTickIn(view: UIView) {
    self.selectedLine = view
    view.addSubview(tickImageView)
    tickImageView.snp.remakeConstraints { make in
      make.centerY.equalTo(view)
      make.left.equalTo(view).offset(24)
    }
    tickImageView.alpha = 0
    UIView.animate(withDuration: 0.1) { [unowned self] in
      self.tickImageView.alpha = 1
    }
  }
}
