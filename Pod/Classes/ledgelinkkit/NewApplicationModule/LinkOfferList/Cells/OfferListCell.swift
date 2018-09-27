//
//  OfferListCell.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 15/02/16.
//
//

import UIKit

open class OfferListCell : UITableViewCell {
  
  fileprivate let lenderIcon = UIImageView()
  fileprivate let lenderName = UILabel()
  fileprivate let interestRateLabel = UILabel()
  fileprivate let interestRateValue = UILabel()
  fileprivate let amountFinancedLabel = UILabel()
  fileprivate let amountFinancedValue = UILabel()
  fileprivate let monthlyPaymentLabel = UILabel()
  fileprivate let monthlyPaymentValue = UILabel()
  fileprivate let moreInfoLabel = UILabel()
  fileprivate let moreInfoFoldLabel = UILabel()
  fileprivate let moreInfoUnfoldButton = UIButton()
  fileprivate let moreInfoFoldButton = UIButton()
  fileprivate let moreInfoContentsLabel = UILabel()
  
  fileprivate var headerRow: UIView!
  fileprivate var interestRow: UIView!
  fileprivate var amountFinancedtRow: UIView!
  fileprivate var monthlyPaymentRow: UIView!
  fileprivate var moreInfoFoldedView: UIView!
  fileprivate var moreInfoUnfoldedView: UIView!
  fileprivate var moreInfoView: UIView!
  fileprivate var lastRow: UIView?
  
  fileprivate let applyButton = UIButton()
  fileprivate var styleInitialized = false
  var cellController:OfferListCellController?
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    let lenderIdView = UIView()
    lenderIcon.isHidden = true
    lenderIdView.addSubview(lenderIcon)
    lenderIcon.snp.makeConstraints { make in
      make.top.right.left.equalTo(lenderIdView)
      make.height.equalTo(60)
      make.width.equalTo(120)
    }
    lenderIdView.addSubview(lenderName)
    lenderName.isHidden = true
    lenderName.snp.makeConstraints { make in
      make.top.right.left.right.equalTo(lenderIdView)
      make.height.equalTo(60)
    }
    applyButton.snp.makeConstraints { make in
      make.height.equalTo(60)
    }

    interestRateLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    interestRateLabel.text = "offer-list.cell.interest-rate".podLocalized()
    amountFinancedLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    amountFinancedLabel.text = "offer-list.cell.amount-financed".podLocalized()
    monthlyPaymentLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    monthlyPaymentLabel.text = "offer-list.cell.monthly-payment".podLocalized()
    interestRateValue.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    amountFinancedValue.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    monthlyPaymentValue.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    interestRateValue.textAlignment = .right
    amountFinancedValue.textAlignment = .right
    monthlyPaymentValue.textAlignment = .right
    moreInfoLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    moreInfoLabel.text = "offer-list.cell.more-info".podLocalized()
    moreInfoFoldLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    moreInfoFoldLabel.text = "offer-list.cell.less-info".podLocalized()
    moreInfoUnfoldButton.setImage(UIImage.imageFromPodBundle("top_down_default")?.asTemplate(), for: UIControlState())
    moreInfoUnfoldButton.addTarget(self, action: #selector(OfferListCell.unfoldMoreInfoTapped), for: .touchUpInside)
    moreInfoFoldButton.setImage(UIImage.imageFromPodBundle("top_up_default")?.asTemplate(), for: UIControlState())
    moreInfoFoldButton.addTarget(self, action: #selector(OfferListCell.foldMoreInfoTapped), for: .touchUpInside)
    moreInfoContentsLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    moreInfoContentsLabel.numberOfLines = 0
    applyButton.setTitle("offer-list.cell.button.apply-now".podLocalized(), for: UIControlState())
    applyButton.setTitleColor(UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0), for: UIControlState())
    applyButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)
    applyButton.addTarget(self, action: #selector(OfferListCell.applyButtonTapped), for: .touchUpInside)
    applyButton.accessibilityLabel = "Apply To Offer Button"

    // Setup Rows
    self.headerRow = self.setupHeader(lenderIdView, rightView: applyButton)
    self.interestRow = self.setupRow(interestRateLabel, rightView: interestRateValue)
    self.amountFinancedtRow = self.setupRow(amountFinancedLabel, rightView: amountFinancedValue)
    self.monthlyPaymentRow = self.setupRow(monthlyPaymentLabel, rightView: monthlyPaymentValue)
    self.moreInfoUnfoldedView = self.setupRow(moreInfoFoldLabel, rightView: moreInfoFoldButton)
    self.moreInfoFoldedView = self.setupRow(moreInfoLabel, rightView: moreInfoUnfoldButton)
    self.moreInfoView = self.setupRow(moreInfoContentsLabel, rightView: nil)
    self.moreInfoUnfoldedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OfferListCell.foldMoreInfoTapped)))
    self.moreInfoFoldedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OfferListCell.unfoldMoreInfoTapped)))
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setUIConfiguration(_ uiConfiguration:ShiftUIConfig) {
    guard !self.styleInitialized else {
      return
    }
    interestRateLabel.font = uiConfiguration.fonth4
    interestRateLabel.backgroundColor = uiConfiguration.offerLabelBackgroundColor
    interestRateLabel.textColor = uiConfiguration.defaultTextColor
    amountFinancedLabel.font = uiConfiguration.fonth4
    amountFinancedLabel.backgroundColor = uiConfiguration.offerLabelBackgroundColor
    amountFinancedLabel.textColor = uiConfiguration.defaultTextColor
    monthlyPaymentLabel.font = uiConfiguration.fonth4
    monthlyPaymentLabel.backgroundColor = uiConfiguration.offerLabelBackgroundColor
    monthlyPaymentLabel.textColor = uiConfiguration.defaultTextColor
    interestRateValue.font = uiConfiguration.fonth4
    interestRateValue.backgroundColor = uiConfiguration.offerValueBackgroundColor
    interestRateValue.textColor = uiConfiguration.defaultTextColor
    amountFinancedValue.font = uiConfiguration.fonth4
    amountFinancedValue.backgroundColor = uiConfiguration.offerValueBackgroundColor
    amountFinancedValue.textColor = uiConfiguration.defaultTextColor
    monthlyPaymentValue.font = uiConfiguration.fonth4
    monthlyPaymentValue.backgroundColor = uiConfiguration.offerValueBackgroundColor
    monthlyPaymentValue.textColor = uiConfiguration.defaultTextColor
    moreInfoLabel.font = uiConfiguration.fonth4
    moreInfoFoldLabel.font = uiConfiguration.fonth4
    applyButton.setTitleColor(uiConfiguration.tintColor, for: UIControlState())
    applyButton.backgroundColor = uiConfiguration.offerApplyButtonBackgroundColor
    applyButton.titleLabel?.font = uiConfiguration.fonth4
    moreInfoUnfoldButton.tintColor = uiConfiguration.tintColor
    moreInfoFoldButton.tintColor = uiConfiguration.tintColor
    self.styleInitialized = true
  }
  
  func set(lenderIconUrl:URL, lenderName: String, result:@escaping Result<Void,NSError>.Callback) {
    self.lenderIcon.setImageUrl(lenderIconUrl) { [weak self] response in
      switch response {
      case .failure(let error):
        self?.lenderIcon.isHidden = true
        self?.lenderName.isHidden = false
        self?.set(lenderName: lenderName)
        result(.failure(error))
      case .success:
        self?.lenderIcon.isHidden = false
        self?.lenderName.isHidden = true
        result(.success(Void()))
      }
    }
  }
  
  func set(lenderName:String) {
    self.lenderName.text = lenderName
    self.lenderName.isHidden = false
    self.lenderIcon.isHidden = !self.lenderName.isHidden
  }

  func set(interestRate:Double) {
    interestRateValue.text = String(format: "%.2f", interestRate)
  }
  
  func set(amountFinanced:Amount) {
    amountFinancedValue.text = amountFinanced.text
  }
  
  func set(monthlyPayment:Amount) {
    monthlyPaymentValue.text = monthlyPayment.text
  }
  
  func set(moreInfo:String?) {
    moreInfoContentsLabel.text = moreInfo
  }
  
  func set(order: Int) {
    applyButton.accessibilityLabel = "Apply To Offer Button \(order)"
  }
  
  func startCellLayout() {
    self.contentView.snp.removeConstraints()
    for view in self.contentView.subviews {
      view.removeFromSuperview()
    }
  }
  
  func showLenderHeader() {
    self.lastRow = nil
    self.addRow(self.headerRow, addSeparator:false)
  }
  
  func showInterestRateRow() {
    self.addRow(self.interestRow, completeSeparator:true)
  }

  func showAmountFinancedRow() {
    self.addRow(self.amountFinancedtRow)
  }

  func showMonthlyPaymentRow() {
    self.addRow(self.monthlyPaymentRow)
  }

  func showMoreInfoFoldedRow() {
    self.addRow(self.moreInfoFoldedView)
  }

  func showMoreInfoUnfoldedRow() {
    self.addRow(self.moreInfoUnfoldedView)
  }

  func showMoreInfoTextRow() {
    self.addRow(self.moreInfoView)
  }

  func finishCellLayout() {
    self.lastRow?.snp.makeConstraints { make in
      make.bottom.equalTo(self.contentView)
    }
    let topBorder = UIView()
    topBorder.backgroundColor = colorize(0xdadada)
    self.contentView.addSubview(topBorder)
    topBorder.snp.makeConstraints { make in
      make.left.top.right.equalTo(self.contentView)
      make.height.equalTo(1 / UIScreen.main.scale)
    }
    let bottomBorder = UIView()
    bottomBorder.backgroundColor = colorize(0xdadada)
    self.contentView.addSubview(bottomBorder)
    bottomBorder.snp.makeConstraints { make in
      make.left.bottom.right.equalTo(self.contentView)
      make.height.equalTo(1 / UIScreen.main.scale)
    }
  }
  
  @objc open func applyButtonTapped() {
    self.cellController?.applyButtonTapped()
  }
  
  @objc open func unfoldMoreInfoTapped() {
    self.cellController?.unfoldMoreInfoTapped()
  }

  @objc open func foldMoreInfoTapped() {
    self.cellController?.foldMoreInfoTapped()
  }
  // MARK: - Private methods

  fileprivate func setupHeader(_ leftView: UIView, rightView: UIView) -> UIView {
    let view = UIView()
    view.addSubview(leftView)
    view.addSubview(rightView)
    leftView.snp.makeConstraints { make in
      make.left.equalTo(view).offset(15)
      make.top.equalTo(view).offset(12)
      make.bottom.equalTo(view).inset(12)
    }
    rightView.snp.makeConstraints { make in
      make.right.equalTo(view).inset(15)
      make.top.centerY.equalTo(leftView)
    }
    return view
  }

  fileprivate func setupRow(_ leftView: UIView, rightView: UIView?) -> UIView {
    let view = UIView()
    view.addSubview(leftView)
    guard let rightView = rightView else {
      leftView.snp.makeConstraints { make in
        make.left.equalTo(view).offset(15)
        make.right.equalTo(view).inset(15)
        make.top.equalTo(view).offset(12)
        make.bottom.equalTo(view).inset(12)
      }
      return view
    }
    
    leftView.snp.makeConstraints { make in
      make.left.equalTo(view).offset(15)
      make.top.equalTo(view).offset(8)
      make.bottom.equalTo(view).inset(8)
    }

    view.addSubview(rightView)
    rightView.snp.makeConstraints { make in
      make.right.equalTo(view).inset(15)
      make.centerY.equalTo(leftView)
    }
    return view
  }
  
  fileprivate func addRow(_ row:UIView, addSeparator: Bool = true, completeSeparator: Bool = false) {
    if addSeparator {
      let separatorView = UIView()
      separatorView.backgroundColor = colorize(0xefefef, alpha:1.0)
      self.contentView.addSubview(separatorView)
      separatorView.snp.makeConstraints{ make in
        make.top.equalTo(lastRow != nil ? lastRow!.snp.bottom : self.contentView.snp.top)
        make.left.equalTo(self.contentView).offset(completeSeparator ? 0 : 15)
        make.right.equalTo(self.contentView)
        make.height.equalTo(1 / UIScreen.main.scale)
      }
      self.contentView.addSubview(row)
      row.snp.makeConstraints { make in
        make.left.right.equalTo(self.contentView)
        make.top.equalTo(separatorView.snp.bottom)
      }
    }
    else {
      self.contentView.addSubview(row)
      row.snp.makeConstraints { make in
        make.top.equalTo(lastRow != nil ? lastRow!.snp.bottom : self.contentView.snp.top)
        make.left.right.equalTo(self.contentView)
      }
    }
    self.lastRow = row
  }

}
