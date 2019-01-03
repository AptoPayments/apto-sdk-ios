//
//  ShiftCardTransactionDetailsViewControllerTheme1.swift
//  ShiftSDK
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

class ShiftCardTransactionDetailsViewControllerTheme1: ShiftViewController, ShiftCardTransactionDetailsViewProtocol {

  private unowned let presenter: ShiftCardTransactionDetailsPresenterProtocol
  private let containerView = UIScrollView()
  private let topView = UIView()
  private let headerView: TransactionHeaderViewTheme1
  private let mapView = MKMapView()
  private let mccIconView = UIImageView()
  private let formView = MultiStepForm()
  private var transparentNavigationBar: Bool = true
  private var showMap: Bool = false
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
    self.headerView = TransactionHeaderViewTheme1(uiConfiguration: uiConfiguration)
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
    updateHeaderViewFrom(viewModel)
    var rows: [FormRowView] = []
    rows.append(contentsOf: addressSectionRowsFrom(viewModel))
    rows.append(contentsOf: basicInfoSectionRowsFrom(viewModel))
    rows.append(contentsOf: detailsInfoSectionRowsFrom(viewModel))
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

  private func addRowIfHasValue(rows: inout [FormRowView], title: String, value: String?) {
    if let value = value {
      rows.append(FormBuilder.labelLabelRowWith(leftText: title,
                                                rightText: value,
                                                labelWidth: nil,
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

  private func updateHeaderViewFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) {
    headerView.set(description: viewModel.description.value, fiatAmount: viewModel.fiatAmount.value)
  }

  private func addressSectionRowsFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) -> [FormRowView] {
    var rows: [FormRowView] = []
    if let address = viewModel.address.value, let iconMapPinImage = UIImage.imageFromPodBundle("icon-map-pin-small") {
      let imageView = UIImageView(image: iconMapPinImage.asTemplate())
      imageView.snp.makeConstraints { make in
        make.width.equalTo(14)
        make.height.equalTo(22)
      }
      imageView.tintColor = uiConfiguration.iconPrimaryColor
      rows.append(FormBuilder.sectionTitleRowWith(text: "transaction_details.address.title".podLocalized(),
                                                  textAlignment: .left,
                                                  uiConfig: uiConfiguration))
      rows.append(FormBuilder.imageLabelRowWith(imageView: imageView,
                                                rightText: address,
                                                textAlignment: .left,
                                                multiLine: true,
                                                uiConfig: uiConfiguration))
    }
    else {
      let separatorView = FormRowSeparatorView(backgroundColor: .clear, height: 12)
      separatorView.padding = .zero
      rows.append(separatorView)
    }
    return rows
  }

  private func basicInfoSectionRowsFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) -> [FormRowView] {
    var rows: [FormRowView] = []
    rows.append(FormBuilder.sectionTitleRowWith(text: "transaction_details.basic_info.title".podLocalized(),
                                                textAlignment: .left,
                                                uiConfig: uiConfiguration))
    addRowIfHasValue(rows: &rows,
                     title: "transaction_details.basic_info.transaction_date.title".podLocalized(),
                     value: viewModel.transactionDate.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction_details.basic_info.transaction_status.title".podLocalized(),
                     value: viewModel.transactionStatus.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction_details.basic_info.category.title".podLocalized(),
                     value: viewModel.category.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction_details.basic_info.funding_source.title".podLocalized(),
                     value: viewModel.fundingSource.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction_details.basic_info.currency_exchange.title".podLocalized(),
                     value: viewModel.currencyExchange.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction_details.basic_info.fee.title".podLocalized(),
                     value: viewModel.fee.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction_details.basic_info.exchange_rate.title".podLocalized(),
                     value: viewModel.exchangeRate.value)
    return rows
  }

  private func detailsInfoSectionRowsFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) -> [FormRowView] {
    var rows: [FormRowView] = []
    rows.append(FormBuilder.sectionTitleRowWith(text: "transaction_details.details.title".podLocalized(),
                                                textAlignment: .left,
                                                uiConfig: uiConfiguration))
    addRowIfHasValue(rows: &rows,
                     title: "transaction_details.details.device_type.title".podLocalized(),
                     value: viewModel.deviceType.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction_details.details.transaction_type.title".podLocalized(),
                     value: viewModel.transactionClass.value)
    addRowIfHasValue(rows: &rows,
                     title: "transaction_details.details.transaction_id.title".podLocalized(),
                     value: viewModel.transactionId.value)
    return rows
  }

  private func adjustmentsSectionRowsFrom(_ viewModel: ShiftCardTransactionDetailsViewModel) -> [FormRowView] {
    var rows: [FormRowView] = []
    if !viewModel.adjustments.isEmpty {
      for adjustment in viewModel.adjustments.array {
        let view = TransactionAdjustmentViewTheme1(uiConfiguration: uiConfiguration)
        var title = ""
        switch adjustment.type {
        case .capture:
          title = String(format: "transaction_details.adjustment.transfer_from.text".podLocalized(),
                         adjustment.fundingSourceName ?? "")
        case .refund:
          title = String(format: "transaction_details.adjustment.transfer_to.text".podLocalized(),
                         adjustment.fundingSourceName ?? "")
        default:
          title = ""
        }
        let externalId = String(format: "transaction_details.adjustment.id.text".podLocalized(),
                                adjustment.externalId ?? "?")
        var exchangeRate: String = ""
        if let adjustmentExchangeRate = adjustment.exchangeRate,
          let localCurrency = adjustment.localAmount?.currencySymbol,
          let nativeCurrency = adjustment.nativeAmount?.currencySymbol {
          exchangeRate = "1 \(nativeCurrency) ≈ \(localCurrency) \(adjustmentExchangeRate.format(".2"))"
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

private extension ShiftCardTransactionDetailsViewControllerTheme1 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
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
    topView.addSubview(headerView)
    headerView.layer.shadowOffset = CGSize(width: 0, height: -2)
    headerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
    headerView.layer.shadowOpacity = 1
    headerView.layer.shadowRadius = 3
    headerView.snp.makeConstraints { make in
      make.bottom.equalTo(topView)
      make.left.right.equalTo(topView)
      make.height.equalTo(basicInfoBarHeight)
    }
    topView.addSubview(transparentView)
    transparentView.snp.makeConstraints { make in
      make.left.top.right.equalTo(topView)
      make.bottom.equalTo(headerView.snp.top)
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

extension ShiftCardTransactionDetailsViewControllerTheme1: UIScrollViewDelegate {
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
        }, completion: nil)
        transparentNavigationBar = true
      }
    }
  }
}
