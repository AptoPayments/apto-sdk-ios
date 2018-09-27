//
//  ShiftCardTransactionDetailsViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import UIKit
import MapKit
import Stripe
import Bond
import ReactiveKit
import SnapKit
import PullToRefreshKit

class ShiftCardTransactionDetailsViewController: ShiftViewController, ShiftCardTransactionDetailsViewProtocol {

  let presenter: ShiftCardTransactionDetailsPresenterProtocol
  private var containerView = UIScrollView()
  private var topView = UIView()
  private var iconDragImageView = UIImageView()
  private var basicInfoMerchantLabel: UILabel?
  private var basicInfoAmountLabel: UILabel?
  private var mapView = MKMapView()
  private var mccIconView = UIImageView()
  private let formView = MultiStepForm()
  private var transparentNavigationBar: Bool = true
  private var showMap: Bool = false
  private static var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("MMMddhhmm")
    return formatter
  }
  private static var dateFormatterWithYear: DateFormatter {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("MMMddYYYYhhmm")
    return formatter
  }
  // Useful for calculations in different device types
  private var statusBarHeight: CGFloat = 20.0
  private var navigationBarHeight: CGFloat = 44.0
  private var basicInfoBarHeight: CGFloat = 88.0
  private var iPhoneXSafeAreaHeight: CGFloat = 24.0
  private var basicInfoBarShrinkDelta: CGFloat = 28.0
  private var mapSpan: Double = 0.01
  private lazy var topViewHeight: CGFloat = { [unowned self] in
    return (UIDevice.deviceType() == .iPhone5) ? 284.0 : 338.0
  }()
  private lazy var systemElementsHeight: CGFloat = { [unowned self] in
    var retVal = basicInfoBarHeight + statusBarHeight + navigationBarHeight
    if UIDevice.deviceType() == .iPhoneX {
      retVal += iPhoneXSafeAreaHeight
    }
    return retVal
  }()
  private lazy var minFormViewHeight: CGFloat = { [unowned self] in
    return view.frame.height - systemElementsHeight + basicInfoBarShrinkDelta
  }()
  private lazy var contentViewMaxOffset: CGFloat = { [unowned self] in
    return topViewHeight - systemElementsHeight + basicInfoBarShrinkDelta
  }()

  init(uiConfiguration: ShiftUIConfig, presenter: ShiftCardTransactionDetailsPresenterProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    presenter.viewLoaded()
  }

  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.navigationBar.setOpaque(uiConfig: uiConfiguration)
    navigationController?.navigationBar.showShadow()
    super.viewWillDisappear(animated)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func finishUpdates() {
    let viewModel = presenter.viewModel
    updateMapFrom(viewModel)
    updateTopBarViewFrom(viewModel)
    var rows: [FormRowView] = []
    rows.append(contentsOf: addressSectionRowsFrom(viewModel))
    rows.append(contentsOf: detailsSectionRowsFrom(viewModel))
    rows.append(contentsOf: transactionInfoSectionRowsFrom(viewModel))
    rows.append(contentsOf: adjustmentsSectionRowsFrom(viewModel))
    rows.append(FormBuilder.separatorRow(height: 24))
    formView.show(rows: rows)
    // If the formView content size is not tall enough, the formView can't be scrolled down when the map is not shown.
    // To prevent that, we add content to the bottom so the formView content will be always bigger than the formView
    // frame
    formView.setNeedsLayout()
    formView.layoutIfNeeded()
    if formView.contentSize.height < minFormViewHeight {
      rows.append(FormBuilder.separatorRow(height: (minFormViewHeight - formView.contentSize.height) + 1))
      formView.show(rows: rows)
    }
    // If map is not shown, hide that section
    if !showMap {
      containerView.setContentOffset(CGPoint(x: 0, y: contentViewMaxOffset), animated: false)
    }
  }

  func showLoadingSpinner() {
    showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
  }

  private func addRowIfHasValue(rows: inout [FormRowView], title: String, value: String?) {
    if let value = value {
      rows.append(FormBuilder.labelLabelRowWith(leftText: title,
                                                rightText: value,
                                                labelWidth: 140,
                                                textAlignment: .right,
                                                showSplitter: false,
                                                backgroundColor: .clear,
                                                uiConfig: uiConfiguration))
    }
  }

  private func updateMapFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) {
    if let latitude = viewModel.latitude.value, let longitude = viewModel.longitude.value {
      let mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      let mapSpan = MKCoordinateSpan(latitudeDelta: self.mapSpan, longitudeDelta: self.mapSpan)
      let region = MKCoordinateRegion(center: mapCenter, span: mapSpan)
      mapView.setRegion(region, animated: true)
      if let mccIcon = viewModel.mccIcon.value {
        mccIconView.image = mccIcon.image()
      }
      showMap = true
    }
    else {
      showMap = false
    }
  }

  private func updateTopBarViewFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) {
    basicInfoAmountLabel?.text = viewModel.topViewAmount.value
    basicInfoMerchantLabel?.text = viewModel.topViewDescription.value
  }

  private func addressSectionRowsFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) -> [FormRowView] {
    var rows: [FormRowView] = []
    if let location = viewModel.location.value, let iconMapPinImage = UIImage.imageFromPodBundle("icon-map-pin-small") {
      rows.append(FormBuilder.sectionTitleRowWith(text: "transaction-details.address.title".podLocalized(),
                                                  textAlignment: .left,
                                                  uiConfig: uiConfiguration))
      let imageView = UIImageView(image: iconMapPinImage.asTemplate())
      imageView.snp.makeConstraints { make in
        make.width.equalTo(14)
        make.height.equalTo(22)
      }
      imageView.tintColor = uiConfiguration.iconPrimaryColor
      rows.append(FormBuilder.imageLabelRowWith(imageView: imageView,
                                                rightText: location,
                                                textAlignment: .left,
                                                multiLine: true,
                                                uiConfig: uiConfiguration))
    }
    return rows
  }

  private func detailsSectionRowsFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) -> [FormRowView] {
    var rows: [FormRowView] = []
    rows.append(FormBuilder.sectionTitleRowWith(text: "transaction-details.details.title".podLocalized(),
                                                textAlignment: .left,
                                                uiConfig: uiConfiguration))

    addRowIfHasValue(rows: &rows,
                     title: "transaction-details.category.title".podLocalized(),
                     value: viewModel.category.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction-details.hold-amount.title".podLocalized(),
                     value: viewModel.holdAmount.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction-details.shift-atm-fee.title".podLocalized(),
                     value: viewModel.shiftAtmFee.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction-details.shift-int-atm-fee.title".podLocalized(),
                     value: viewModel.shiftIntAtmFee.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction-details.shift-int-fee.title".podLocalized(),
                     value: viewModel.shiftIntFee.value)
    if let transactionDate = viewModel.transactionDate.value {
      var formattedDate: String = ""
      if Date().year > transactionDate.year {
        formattedDate += ShiftCardTransactionDetailsViewController.dateFormatterWithYear.string(from: transactionDate)
      }
      else {
        formattedDate = ShiftCardTransactionDetailsViewController.dateFormatter.string(from: transactionDate)
      }
      addRowIfHasValue(
        rows: &rows,
        title: "transaction-details.transaction-date.title".podLocalized(),
        value: formattedDate)
    }
    return rows
  }

  private func transactionInfoSectionRowsFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) -> [FormRowView] {
    var rows: [FormRowView] = []
    rows.append(FormBuilder.sectionTitleRowWith(text: "transaction-details.transaction-info.title".podLocalized(),
                                                textAlignment: .left,
                                                uiConfig: uiConfiguration))
    addRowIfHasValue(rows: &rows,
                     title: "transaction-details.transaction-type.title".podLocalized(),
                     value: viewModel.type.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction-details.shift-id.title".podLocalized(),
                     value: viewModel.shiftId.value)
    return rows
  }

  private func adjustmentsSectionRowsFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) -> [FormRowView] {
    var rows: [FormRowView] = []
    if !viewModel.adjustments.isEmpty {
      for adjustment in viewModel.adjustments.array {
        let view = TransactionAdjustmentView(uiConfiguration: uiConfiguration)
        var title = ""
        switch adjustment.type {
        case .capture:
          title = String(format: "transaction-details.transfer-from.text".podLocalized(),
                         adjustment.fundingSourceName ?? "")
        case .refund:
          title = String(format: "transaction-details.transfer-to.text".podLocalized(),
                         adjustment.fundingSourceName ?? "")
        default:
          title = ""
        }
        let externalId = String(format: "transaction-details.external-id.text".podLocalized(),
                                adjustment.externalId ?? "?")
        var exchangeRate: String = ""
        if let nativeCurrency = adjustment.nativeAmount?.currency.value,
          let localCurrency = adjustment.localAmount?.currency.value,
          let adjustmentExchangeRate = adjustment.exchangeRate {
          let adjustedLocalAmount = Amount(value: adjustmentExchangeRate, currency: localCurrency)
          exchangeRate = "1 \(nativeCurrency) = \(adjustedLocalAmount.text)"
        }
        view.set(title: title,
                 id: externalId,
                 exchangeRate: exchangeRate,
                 amount: adjustment.localAmount,
                 adjustmentType: adjustment.type)
        let formRowView = FormRowCustomView(view: view, showSplitter: false)
        formRowView.padding = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        formRowView.backgroundColor = .clear
        rows.append(formRowView)
      }
    }
    return rows
  }

  override func previousTapped() {
    presenter.previousTapped()
  }

}

private extension ShiftCardTransactionDetailsViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.backgroundColor
    extendedLayoutIncludesOpaqueBars = true
    setupMapView()
    setUpNavigationBar()
    setupContainerView()
    setUpTopView()
    setupTransactionDetailsView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setTransparent()
  }

  func setupContainerView() {
    view.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.top.equalTo(view)
      make.left.right.bottom.equalTo(view)
    }
    containerView.delegate = self
    containerView.isScrollEnabled = false
  }

  func setupMapView() {
    view.addSubview(mapView)
    mapView.snp.makeConstraints { make in
      make.top.equalTo(view)
      make.left.right.equalTo(view)
      make.width.equalTo(view)
      make.height.equalTo(topViewHeight - basicInfoBarHeight)
    }
    if let pinImage = UIImage.imageFromPodBundle("icon-map-pin-big") {
      let pinImageView = UIImageView(image: pinImage.asTemplate())
      pinImageView.tintColor = uiConfiguration.uiSecondaryColor
      mapView.addSubview(pinImageView)
      pinImageView.snp.makeConstraints { make in
        make.centerX.equalTo(mapView)
        make.centerY.equalTo(mapView)
      }
      pinImageView.addSubview(mccIconView)
      mccIconView.snp.makeConstraints { make in
        make.centerX.equalTo(pinImageView)
        make.centerY.equalTo(pinImageView).offset(-6)
        make.width.height.equalTo(44)
      }
    }
    if let imageGradient = UIImage.imageFromPodBundle("map-gradient") {
      let gradientView = UIView()
      gradientView.backgroundColor = UIColor(patternImage: imageGradient)
      mapView.addSubview(gradientView)
      gradientView.snp.makeConstraints { make in
        make.left.top.right.equalTo(mapView)
        make.height.equalTo(152)
      }
    }
  }

  func setUpTopView() {
    containerView.addSubview(topView)
    topView.snp.makeConstraints { make in
      make.top.equalTo(containerView)
      make.left.right.equalTo(containerView)
      make.width.equalTo(containerView)
      make.height.equalTo(topViewHeight)
    }
    let transparentView = UIView()
    transparentView.addTapGestureRecognizer { [weak self] in
      self?.presenter.mapTapped()
    }

    let basicInfoView = UIView()
    topView.addSubview(basicInfoView)
    basicInfoView.backgroundColor = uiConfiguration.uiPrimaryColor
    basicInfoView.layer.shadowOffset = CGSize(width: 0, height: -2)
    basicInfoView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
    basicInfoView.layer.shadowOpacity = 1
    basicInfoView.layer.shadowRadius = 3
    basicInfoView.snp.makeConstraints { make in
      make.bottom.equalTo(topView)
      make.left.right.equalTo(topView)
      make.height.equalTo(basicInfoBarHeight)
    }

    if let iconDragImage = UIImage.imageFromPodBundle("icon-drag") {
      basicInfoView.addSubview(iconDragImageView)
      iconDragImageView.tintColor = uiConfiguration.textTopBarColor
      iconDragImageView.image = iconDragImage.asTemplate()
      iconDragImageView.snp.makeConstraints { make in
        make.centerX.equalTo(basicInfoView)
        make.width.equalTo(36)
        make.top.equalTo(6)
      }
    }
    let basicInfoAmountLabel = ComponentCatalog.amountMediumLabelWith(text: "", uiConfig: uiConfiguration)
    basicInfoView.addSubview(basicInfoAmountLabel)
    basicInfoAmountLabel.textColor = uiConfiguration.textTopBarColor
    basicInfoAmountLabel.snp.makeConstraints { make in
      make.centerY.equalTo(basicInfoView).offset(4)
      make.right.equalTo(basicInfoView).inset(16)
    }
    self.basicInfoAmountLabel = basicInfoAmountLabel
    let basicInfoMerchantLabel = ComponentCatalog.topBarTitleBigLabelWith(text: "",
                                                                          textAlignment: .left,
                                                                          uiConfig: uiConfiguration)
    basicInfoMerchantLabel.numberOfLines = 2
    basicInfoView.addSubview(basicInfoMerchantLabel)
    basicInfoMerchantLabel.textColor = uiConfiguration.textTopBarColor
    basicInfoMerchantLabel.snp.makeConstraints { make in
      make.centerY.equalTo(basicInfoView).offset(4)
      make.left.equalTo(basicInfoView).offset(16)
      make.right.equalTo(basicInfoAmountLabel.snp.left).offset(-24)
    }
    self.basicInfoMerchantLabel = basicInfoMerchantLabel

    topView.addSubview(transparentView)
    transparentView.snp.makeConstraints { make in
      make.left.top.right.equalTo(topView)
      make.bottom.equalTo(basicInfoView.snp.top)
    }

  }

  func setupTransactionDetailsView() {
    containerView.addSubview(formView)
    formView.backgroundColor = .white
    formView.snp.makeConstraints { make in
      make.top.equalTo(topView.snp.bottom)
      make.left.right.bottom.equalTo(containerView)
      make.bottom.equalTo(view)
    }
    formView.delegate = self
  }

}

extension ShiftCardTransactionDetailsViewController: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if !showMap && containerView.contentOffset.y < contentViewMaxOffset {
      containerView.contentOffset.y = contentViewMaxOffset
    }
    if scrollView == formView && showMap {
      if formView.contentOffset.y > 0 && containerView.contentOffset.y < contentViewMaxOffset {
        containerView.contentOffset.y = max(min(containerView.contentOffset.y + formView.contentOffset.y,
                                                contentViewMaxOffset), 0)
        formView.contentOffset.y = 0
      }
      else if formView.contentOffset.y < 0 && containerView.contentOffset.y > 0 {
        containerView.contentOffset.y = max(min(containerView.contentOffset.y + formView.contentOffset.y,
                                                contentViewMaxOffset), 0)
        formView.contentOffset.y = 0
      }
    }
    if containerView.contentOffset.y >= contentViewMaxOffset {
      if transparentNavigationBar, let navigationBar = navigationController?.navigationBar {
        UIView.transition(with: navigationBar, duration: 0.15,
                          options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                            navigationBar.setOpaque(uiConfig: self.uiConfiguration)
                            self.iconDragImageView.isHidden = true
        }, completion: nil)
        navigationBar.hideShadow()
        transparentNavigationBar = false
      }
    }
    else {
      if !transparentNavigationBar, let navigationBar = navigationController?.navigationBar {
        UIView.transition(with: navigationBar, duration: 0.15,
                          options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                            navigationBar.setTransparent()
                            self.iconDragImageView.isHidden = false
        }, completion: nil)
        transparentNavigationBar = true
      }
    }
  }
}
