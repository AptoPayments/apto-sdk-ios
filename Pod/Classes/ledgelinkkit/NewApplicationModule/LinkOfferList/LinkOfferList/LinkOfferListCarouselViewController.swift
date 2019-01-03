//
//  OfferListCarouselViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/08/16.
//
//

import UIKit
import UIScrollView_InfiniteScroll

class LinkOfferListCarouselViewController: ShiftViewController, LinkOfferListView {

  var eventHandler: LinkOfferListEventHandler
  fileprivate let topView = UIView()
  fileprivate let lenderIcon = UIImageView()
  fileprivate let lenderNameLabel = UILabel()
  fileprivate let congratzLabel = UILabel()
  fileprivate let applyButton = UIButton()
  fileprivate let formView = MultiStepForm()
  fileprivate var detailsForm: OfferDetailsForm!
  fileprivate var currentOffer: LoanOffer?
  fileprivate var navigationMenu: NavigationMenu?

  init(uiConfiguration: ShiftUIConfig, eventHandler: LinkOfferListEventHandler) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {

    title = "offer-list-carousel.title".podLocalized()
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor

    setupTopView()

    view.addSubview(formView)
    formView.snp.makeConstraints { make in
      make.left.right.top.bottom.equalTo(view)
    }

    navigationMenu = NavigationMenu(viewController: self, uiConfiguration: self.uiConfiguration, menuListener: eventHandler)
    navigationMenu?.install()
    showNavCancelButton(self.uiConfiguration.iconTertiaryColor)
    eventHandler.viewLoaded()
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  // MARK: - OfferListViewProtocol

  func showNewContents(_ newContents:[LoanOffer], append:Bool) {
    // MARK: v1: show only the first offer in the list
    guard let firstOffer = newContents.first else {
      self.currentOffer = nil
      return
    }
    self.currentOffer = firstOffer
    detailsForm = OfferDetailsForm(offer: firstOffer, uiConfig: self.uiConfiguration)
    var rows = [FormRowView]()

    rows.append(FormRowCustomView(view: topView))
    rows.append(FormBuilder.topSeparatorRow())
    rows.append(contentsOf: detailsForm.setupRows())
    rows.append(FormBuilder.bottomSeparatorRow())

    if let richText = firstOffer.customMessage?.formattedHtmlString(font: self.uiConfiguration.fonth6,
                                                                    color: self.uiConfiguration.noteTextColor,
                                                                    linkColor: self.uiConfiguration.tintColor) {
      let disclosureLabel = FormBuilder.richTextNoteRowWith(text: richText,
                                                            textAlignment: .justified,
                                                            position: .top,
                                                            uiConfig: self.uiConfiguration,
                                                            linkHandler: eventHandler.linkHandler)
      disclosureLabel.label.numberOfLines = 0
      disclosureLabel.backgroundColor = self.uiConfiguration.uiBackgroundPrimaryColor
      disclosureLabel.label.backgroundColor = self.uiConfiguration.uiBackgroundPrimaryColor
      rows.append(disclosureLabel)
    }

    self.formView.show(rows: rows)
    self.set(lenderIconUrl: firstOffer.lender.bigIconUrl, lenderName: firstOffer.lender.name)
  }

  // MARK: Private

  fileprivate var lenderName: String!

  fileprivate func setupTopView() {
    topView.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor

    lenderNameLabel.isHidden = true
    lenderNameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 24)!
    topView.addSubview(lenderNameLabel)
    lenderNameLabel.snp.makeConstraints { make in
      make.centerX.equalTo(topView)
      make.top.equalTo(topView).offset(40)
      make.height.equalTo(60)
    }

    lenderIcon.isHidden = true
    topView.addSubview(lenderIcon)
    lenderIcon.snp.makeConstraints { make in
      make.centerX.right.equalTo(topView)
      make.top.equalTo(topView).offset(40)
      make.height.equalTo(60)
    }

    congratzLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
    topView.addSubview(congratzLabel)
    congratzLabel.numberOfLines = 0
    congratzLabel.textAlignment = .center
    congratzLabel.snp.makeConstraints { make in
      make.top.equalTo(lenderNameLabel.snp.bottom).offset(40)
      make.left.right.equalTo(topView).inset(20)
    }

    topView.addSubview(applyButton)
    applyButton.snp.makeConstraints { make in
      make.top.equalTo(congratzLabel.snp.bottom).offset(40)
      make.bottom.equalTo(topView).inset(40)
      make.height.equalTo(44)
      make.width.equalTo(240)
      make.centerX.equalTo(topView)
    }

    applyButton.layer.masksToBounds = true
    applyButton.layer.cornerRadius = 5
    applyButton.clipsToBounds = true
    applyButton.backgroundColor = uiConfiguration.tintColor
    applyButton.setTitle("offer-list-carousel.button.apply-now".podLocalized(), for: UIControlState())
    applyButton.addTarget(self, action: #selector(self.applyButtonTapped), for: .touchUpInside)
  }

  fileprivate func set(lenderIconUrl:URL?, lenderName: String, result:Result<Void,NSError>.Callback? = nil) {
    self.lenderName = lenderName
    guard let imageUrl = lenderIconUrl else {
      self.set(lenderName: lenderName)
      self.lenderIcon.isHidden = true
      self.lenderNameLabel.isHidden = false
      result?(.success(Void()))
      return
    }
    self.lenderIcon.setImageUrl(imageUrl) { [weak self] response in
      switch response {
      case .failure(let error):
        self?.set(lenderName: lenderName)
        result?(.failure(error))
      case .success:
        self?.lenderIcon.isHidden = false
        self?.lenderNameLabel.isHidden = true
        result?(.success(Void()))
      }
    }
  }

  func set(borrowerName:String?) {
    guard let name = borrowerName else {
      congratzLabel.text = "offer-list-carousel.preapproved".podLocalized().replace(["(%lender_name%)":lenderName])
      return
    }
    congratzLabel.text = "offer-list-carousel.borrower_preapproved".podLocalized().replace(["(%borrower_name%)":name, "(%lender_name%)":lenderName])
  }

  fileprivate func set(lenderName:String) {
    self.lenderNameLabel.text = lenderName
    self.lenderNameLabel.isHidden = false
    self.lenderIcon.isHidden = !self.lenderNameLabel.isHidden
  }

  @objc func applyButtonTapped() {
    guard let offer = self.currentOffer else {
      return
    }
    eventHandler.applyToOfferTapped(offer)
  }
}
