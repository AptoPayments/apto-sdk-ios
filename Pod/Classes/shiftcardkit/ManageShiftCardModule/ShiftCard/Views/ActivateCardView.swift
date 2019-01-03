//
//  ActivateCardView.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/09/2018.
//
//

import SnapKit

protocol ActivateCardViewDelegate: class {
  func activateCardTapped()
}

class ActivateCardView: UIView {
  private let uiConfig: ShiftUIConfig
  weak var delegate: ActivateCardViewDelegate?

  init(uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
    super.init(frame: .zero)
    setUpUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    setUpUI()
  }
}

private extension ActivateCardView {
  func setUpUI() {
    let button = createActivateButton()
    let explanationLabel = createExplanationLabel(bottomView: button)
    setUpTitleLabel(bottomView: explanationLabel)
  }

  func createActivateButton() -> UIButton {
    let button = ComponentCatalog.buttonWith(title: "manage.shift.card.activate-card-button.title".podLocalized(),
                                             uiConfig: uiConfig) { [unowned self] in
      self.delegate?.activateCardTapped()
    }
    addSubview(button)
    button.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview().inset(margins)
    }
    return button
  }

  func createExplanationLabel(bottomView: UIView) -> UILabel {
    let explanation = "manage.shift.card.activate-card.explanation".podLocalized()
    let label = ComponentCatalog.mainItemRegularLabelWith(text: explanation, multiline: true, uiConfig: uiConfig)
    addSubview(label)
    label.snp.makeConstraints { make in
      make.bottom.equalTo(bottomView.snp.top).offset(-buttonExplanationMargin)
      make.left.right.equalTo(bottomView)
    }
    return label
  }

  func setUpTitleLabel(bottomView: UIView) {
    let title = "manage.shift.card.activate-card.title".podLocalized()
    let label = ComponentCatalog.largeTitleLabelWith(text: title, uiConfig: uiConfig)
    addSubview(label)
    label.snp.makeConstraints { make in
      make.bottom.equalTo(bottomView.snp.top).offset(-16)
      make.left.right.equalTo(bottomView)
      make.top.equalToSuperview().offset(16)
    }
  }

  private var margins: Int {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return 16
    case .iPhone678:
      return 32
    default:
      return 44
    }
  }

  private var buttonExplanationMargin: Int {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return 20
    case .iPhone678:
      return 40
    default:
      return 64
    }
  }
}
