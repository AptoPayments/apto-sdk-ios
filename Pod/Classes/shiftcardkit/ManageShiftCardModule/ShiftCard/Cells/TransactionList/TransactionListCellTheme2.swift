//
// TransactionListCellTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-12-14.
//

import UIKit
import SnapKit

class TransactionListCellTheme2: UITableViewCell {
  private let iconBackgroundView = UIView()
  private let mccIcon = UIImageView()
  private let descriptionLabel = UILabel()
  private let dateLabel = UILabel()
  private let amountLabel = UILabel()
  private let nativeAmountLabel = UILabel()
  private let bottomDividerView = UIView()
  private var styleInitialized = false
  private static var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("MMMMddhhmm")
    return formatter
  }

  var isLastCellInSection: Bool = false {
    didSet {
      bottomDividerView.isHidden = isLastCellInSection
    }
  }

  weak var cellController: TransactionListCellControllerTheme2?

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setUIConfiguration(_ uiConfiguration: ShiftUIConfig) {
    guard !self.styleInitialized else {
      return
    }
    contentView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    iconBackgroundView.backgroundColor = uiConfiguration.uiTertiaryColor
    mccIcon.tintColor = uiConfiguration.iconSecondaryColor
    descriptionLabel.font = uiConfiguration.fontProvider.mainItemRegularFont
    descriptionLabel.textColor = uiConfiguration.textPrimaryColor
    dateLabel.font = uiConfiguration.fontProvider.timestampFont
    dateLabel.textColor = uiConfiguration.textTertiaryColor
    amountLabel.font = uiConfiguration.fontProvider.amountSmallFont
    amountLabel.textColor = uiConfiguration.textPrimaryColor
    nativeAmountLabel.font = uiConfiguration.fontProvider.timestampFont
    nativeAmountLabel.textColor = uiConfiguration.textTertiaryColor
    bottomDividerView.backgroundColor = uiConfiguration.uiTertiaryColor
    self.styleInitialized = true
  }

  func set(mcc: MCC?, amount: Amount?, nativeAmount: Amount?, transactionDescription: String?, date: Date) {
    iconBackgroundView.isHidden = false
    amountLabel.isHidden = false
    descriptionLabel.isHidden = false
    dateLabel.isHidden = false
    nativeAmountLabel.isHidden = false
    mccIcon.image = mcc?.iconTemplate()
    amountLabel.text = amount?.text
    descriptionLabel.text = transactionDescription?.capitalized
    dateLabel.text = TransactionListCellTheme2.dateFormatter.string(from: date)
    nativeAmountLabel.text = nativeAmount?.text
  }
}

private extension TransactionListCellTheme2 {
  func setUpUI() {
    setUpIcon()
    let view = createContentView()
    setUpAmountLabel(superview: view)
    setUpDescriptionLabel(superview: view)
    setUpDateLabel(superview: view)
    setUpNativeAmountLabel(superview: view)
    setUpBottomDivider()
  }

  func setUpIcon() {
    contentView.addSubview(iconBackgroundView)
    iconBackgroundView.layer.cornerRadius = 20
    iconBackgroundView.isHidden = true
    iconBackgroundView.snp.makeConstraints { make in
      make.width.height.equalTo(40)
      make.left.equalToSuperview().offset(20)
      make.top.equalToSuperview().offset(19)
      make.bottom.equalToSuperview().inset(13)
    }
    mccIcon.contentMode = .center
    iconBackgroundView.addSubview(mccIcon)
    mccIcon.snp.makeConstraints { make in
      make.width.height.equalTo(24)
      make.center.equalToSuperview()
    }
  }

  private func createContentView() -> UIView {
    let view = UIView()
    contentView.addSubview(view)
    view.snp.makeConstraints { make in
      make.left.equalTo(iconBackgroundView.snp.right).offset(16)
      make.right.equalTo(self).inset(20)
      make.top.equalTo(self).inset(17)
      make.bottom.equalTo(self).inset(15)
    }
    return view
  }

  func setUpAmountLabel(superview: UIView) {
    amountLabel.isHidden = true
    amountLabel.textAlignment = .right
    superview.addSubview(amountLabel)
    amountLabel.snp.makeConstraints { make in
      make.top.right.equalToSuperview()
    }
  }

  func setUpDescriptionLabel(superview: UIView) {
    descriptionLabel.isHidden = true
    descriptionLabel.lineBreakMode = .byTruncatingTail
    descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    superview.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.bottom.equalTo(amountLabel)
      make.right.equalTo(amountLabel.snp.left).offset(-24)
    }
  }

  func setUpDateLabel(superview: UIView) {
    dateLabel.isHidden = true
    superview.addSubview(dateLabel)
    dateLabel.snp.makeConstraints { make in
      make.left.bottom.equalToSuperview()
    }
  }

  func setUpNativeAmountLabel(superview: UIView) {
    nativeAmountLabel.isHidden = true
    nativeAmountLabel.textAlignment = .right
    superview.addSubview(nativeAmountLabel)
    nativeAmountLabel.snp.makeConstraints { make in
      make.bottom.right.equalToSuperview()
    }
  }

  func setUpBottomDivider() {
    contentView.addSubview(bottomDividerView)
    bottomDividerView.snp.makeConstraints { make in
      make.height.equalTo(1)
      make.left.equalTo(iconBackgroundView.snp.right).offset(16)
      make.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
    }
  }
}
