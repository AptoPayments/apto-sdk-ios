//
//  TransactionListCellTheme1.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 20/03/18.
//
//

import UIKit

open class TransactionListCellTheme1: UITableViewCell {
  private let mccIcon = UIImageView()
  private let descriptionLabel = UILabel()
  private let dateLabel = UILabel()
  private let amountLabel = UILabel()
  private var styleInitialized = false
  private static var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("MMMMddhhmm")
    return formatter
  }

  var cellController: TransactionListCellControllerTheme1?

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
    contentView.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    mccIcon.tintColor = uiConfiguration.iconSecondaryColor
    descriptionLabel.font = uiConfiguration.fontProvider.mainItemRegularFont
    descriptionLabel.textColor = uiConfiguration.textPrimaryColor
    dateLabel.font = uiConfiguration.fontProvider.timestampFont
    dateLabel.textColor = uiConfiguration.textTertiaryColor
    amountLabel.font = uiConfiguration.fontProvider.amountSmallFont
    amountLabel.textColor = uiConfiguration.textPrimaryColor
    self.styleInitialized = true
  }

  func set(mcc: MCC?, amount: Amount?, transactionDescription: String?, date: Date) {
    mccIcon.image = mcc?.iconTemplate()
    descriptionLabel.text = transactionDescription?.capitalized
    dateLabel.text = TransactionListCellTheme1.dateFormatter.string(from: date)
    amountLabel.text = amount?.text
    mccIcon.isHidden = false
    descriptionLabel.isHidden = false
    dateLabel.isHidden = false
    amountLabel.isHidden = false
  }
}

private extension TransactionListCellTheme1 {
  func setUpUI() {
    setUpIcon()
    let view = createContentView()
    setUpDescriptionLabel(superview: view)
    setUpAmountLabel(superview: view)
    setUpDateLabel(superview: view)
  }

  func setUpIcon() {
    mccIcon.isHidden = true
    mccIcon.contentMode = .center
    self.addSubview(mccIcon)
    mccIcon.snp.makeConstraints { make in
      make.width.height.equalTo(24)
      make.centerY.equalTo(self)
      make.left.equalTo(self).offset(20)
    }
  }

  private func createContentView() -> UIView {
    let view = UIView()
    self.addSubview(view)
    view.snp.makeConstraints { make in
      make.left.equalTo(mccIcon.snp.right).offset(16)
      make.right.equalTo(self).inset(18)
      make.top.bottom.equalTo(self).inset(12)
    }
    return view
  }

  func setUpAmountLabel(superview: UIView) {
    amountLabel.isHidden = true
    amountLabel.textAlignment = .right
    superview.addSubview(amountLabel)
    amountLabel.snp.makeConstraints { make in
      make.centerY.right.equalToSuperview()
      make.left.equalTo(descriptionLabel.snp.right).offset(24)
    }
  }

  func setUpDescriptionLabel(superview: UIView) {
    descriptionLabel.isHidden = true
    superview.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.left.top.equalToSuperview()
    }
  }

  func setUpDateLabel(superview: UIView) {
    dateLabel.isHidden = true
    superview.addSubview(dateLabel)
    dateLabel.snp.makeConstraints { make in
      make.left.bottom.equalTo(superview)
      make.top.equalTo(descriptionLabel.snp.bottom)
      make.right.equalTo(descriptionLabel)
    }
  }
}

private var mccIconsCacheAssociationKey: UInt8 = 63

extension MCC {
  var iconsCache: [String: UIImage] {
    get {
      guard let retVal = objc_getAssociatedObject(self, &mccIconsCacheAssociationKey) as? [String: UIImage] else {
        let iconsCacheData: [String: UIImage] = [:]
        objc_setAssociatedObject(self,
                                 &mccIconsCacheAssociationKey,
                                 iconsCacheData,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return iconsCacheData
      }
      return retVal
    }
    set(newValue) {
      objc_setAssociatedObject(self,
                               &mccIconsCacheAssociationKey,
                               newValue,
                               objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
  }

  public func iconTemplate() -> UIImage? {
    var iconsCache = self.iconsCache
    if let iconTemplate = self.iconsCache[self.icon.rawValue] {
      return iconTemplate
    }
    else {
      let iconTemplate = self.image()?.asTemplate()
      iconsCache[self.icon.rawValue] = iconTemplate
      return iconTemplate
    }
  }
}
