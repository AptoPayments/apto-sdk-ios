//
//  FundingSourceEmptyCaseView.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 16/10/2018.
//

import SnapKit

protocol FundingSourceEmptyCaseViewDelegate {
  func addFundingSourceTapped()
}

class FundingSourceEmptyCaseView: UIView {
  private let uiConfig: ShiftUIConfig

  var delegate: FundingSourceEmptyCaseViewDelegate?

  init(uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
    super.init(frame: .zero)

    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Set up UI
private extension FundingSourceEmptyCaseView {
  func setUpUI() {
    backgroundColor = uiConfig.backgroundColor
    let imageView = createImageView()
    let label = createMessageLabel(topView: imageView)
    createAddFundingSourceButton(topView: label)
  }

  func createImageView() -> UIImageView {
    let imageView = UIImageView(image: UIImage.imageFromPodBundle("emptycase-funding-sources-icon")?.asTemplate())
    imageView.tintColor = uiConfig.iconSecondaryColor
    addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.height.width.equalTo(67)
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(20)
    }
    return imageView
  }

  func createMessageLabel(topView: UIView) -> UILabel {
    let label = ComponentCatalog.sectionTitleLabelWith(text: "funding-source-empty-case.title".podLocalized(),
                                                       uiConfig: uiConfig)
    label.numberOfLines = 0
    label.textColor = uiConfig.textTertiaryColor
    label.textAlignment = .center
    addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalTo(topView.snp.bottom).offset(8)
      make.left.equalToSuperview().offset(64)
      make.right.equalToSuperview().inset(64)
    }
    return label
  }

  func createAddFundingSourceButton(topView: UIView) {
    let button = ComponentCatalog.buttonWith(title: "funding-source-empty-case.action".podLocalized(),
                                             uiConfig: uiConfig) { [unowned self] in
      self.delegate?.addFundingSourceTapped()
    }
    addSubview(button)
    button.snp.makeConstraints { make in
      make.top.equalTo(topView.snp.bottom).offset(20)
      make.left.equalToSuperview().offset(44)
      make.right.equalToSuperview().inset(44)
      make.bottom.equalToSuperview().inset(16)
    }
  }
}
