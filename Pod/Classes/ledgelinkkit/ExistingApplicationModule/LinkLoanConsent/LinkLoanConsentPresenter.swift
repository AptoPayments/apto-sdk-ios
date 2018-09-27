//
//  LoanConsentPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/04/16.
//
//

import Bond
import TTTAttributedLabel

protocol LinkLoanConsentRouterProtocol: URLHandlerProtocol {
  func backFromLoanconsent(_ animated:Bool?)
}

protocol LinkLoanConsentViewControllerProtocol: ViewControllerProtocol {
}

protocol LinkLoanConsentInteractorProtocol {
  func loadApplicationData(_ completion:Result<LoanApplication, NSError>.Callback)
}

class LinkLoanConsentViewModel {
  let lenderIconUrl: Observable<URL?> = Observable(nil)
  let lenderName: Observable<String> = Observable("")
  let signed: Observable<Bool> = Observable(false)
  let rows: Observable<[FormRowView]?> = Observable(nil)
  init() {}
  init(lenderIconUrl:URL?, lenderName:String) {
    self.lenderIconUrl.next(lenderIconUrl)
    self.lenderName.next(lenderName)
  }
}

class LinkLoanConsentPresenter: LinkLoanConsentEventHandlerProtocol {

  var interactor: LinkLoanConsentInteractorProtocol!
  var router: LinkLoanConsentRouterProtocol!
  let viewModel = LinkLoanConsentViewModel()
  var view: LinkLoanConsentViewControllerProtocol!
  let config: LinkConfiguration
  let uiConfiguration: ShiftUIConfig
  fileprivate var linkHandler: LinkHandler?

  init(config: LinkConfiguration, uiConfiguration: ShiftUIConfig) {
    self.config = config
    self.uiConfiguration = uiConfiguration
  }

  func viewLoaded() {
    self.loadApplicationData()
  }

  func loadApplicationData() {
    interactor.loadApplicationData { [weak self] result in
      guard let wself = self else {
        return
      }
      switch result {
      case .failure(let error):
        wself.view.show(error: error)
      case .success(let application):
        wself.setup(viewModel: wself.viewModel, application: application)
        wself.setupDefaultRows(viewModel: wself.viewModel, uiConfig:wself.uiConfiguration , application: application)
      }
    }
  }

  func previousTapped() {
    self.router.backFromLoanconsent(true)
  }

  func agreeTermsTapped() {
    if viewModel.signed.value == false {
      view.showMessage("loan-consent.must-accent-conditions".podLocalized())
    }
    else {
      view.showMessage("Coming Soon!")
    }
  }

  // MARK: - Private methods

  fileprivate func setup(viewModel:LinkLoanConsentViewModel, application: LoanApplication) {
    viewModel.lenderIconUrl.next(application.offer.lender.bigIconUrl)
    viewModel.lenderName.next(application.offer.lender.name)
  }

  func setupDefaultRows(
    viewModel:LinkLoanConsentViewModel,
              uiConfig:ShiftUIConfig,
              application: LoanApplication)
  {

    var rows: [FormRowView] = []

    if application.offer.lender.bigIconUrl != nil {
      let imageView = UIImageView()
      imageView.setImageUrl(application.offer.lender.bigIconUrl!)
      let imageRow = FormRowImageView(
        imageView: imageView,
        height: 120)
      rows.append(imageRow)
    }
    else {
      let lenderName = FormRowLabelView(
        label: self.lenderNameLabel(uiConfig, label:application.offer.lender.name),
        showSplitter: false,
        height: 120)
      rows.append(lenderName)
    }

    let detailsForm = OfferDetailsForm(offer: application.offer, uiConfig: uiConfig)

    rows.append(FormBuilder.topSeparatorRow())
    rows.append(contentsOf: detailsForm.setupRows())
    rows.append(FormBuilder.bottomSeparatorRow())

    let loanProduct = self.config.loanProducts.filter { $0.loanProductId == application.offer.loanProductId }.first

    if loanProduct != nil {

      if let richText = loanProduct?.esignDisclaimer?.attributedString(font: uiConfig.fonth6,
                                                                       color: uiConfig.noteTextColor,
                                                                       linkColor: uiConfig.tintColor) {
        let middleTitle = FormRowLabelView(
          label: self.sectionTitleLabel(uiConfig, label:"loan-consent.borrower-agreement.title".podLocalized()),
          showSplitter: false,
          height: 20)
        middleTitle.backgroundColor = uiConfig.sectionTitleBackgroundColor
        rows.append(middleTitle)
        rows.append(FormBuilder.bottomSeparatorRow())

        linkHandler = LinkHandler(urlHandler:router)
        let disclosureLabel = FormBuilder.richTextNoteRowWith(text: richText,
                                                              textAlignment: .justified,
                                                              position: .top,
                                                              uiConfig: uiConfig,
                                                              linkHandler: linkHandler)
        disclosureLabel.label.numberOfLines = 0
        disclosureLabel.backgroundColor = uiConfig.cardBackgroundColor
        disclosureLabel.label.backgroundColor = uiConfig.cardBackgroundColor
        rows.append(disclosureLabel)
      }

      if let consentRichText = loanProduct?.esignConsentDisclaimer?.attributedString(font: uiConfig.fonth6, color: uiConfig.noteTextColor, linkColor: uiConfig.tintColor) {
        let signLabel = self.signLabel(uiConfig, label: consentRichText)
        signLabel.numberOfLines = 0
        let signRow = FormRowCheckView(label: signLabel)
        signRow.checkIcon.tintColor = uiConfig.tintColor
        rows.append(signRow)
        signRow.bndValue.bind(to:viewModel.signed)
      }
    }

    viewModel.rows.next(rows)
  }

  func lenderNameLabel (_ uiConfig:ShiftUIConfig, label:String) -> UILabel {
    let retVal = UILabel()
    retVal.text = label
    retVal.font = uiConfig.fonth1
    retVal.textColor = uiConfig.defaultTextColor
    retVal.textAlignment = .center
    return retVal
  }

  func sectionTitleLabel (_ uiConfig:ShiftUIConfig, label:String) -> UILabel {
    let retVal = UILabel()
    retVal.text = label
    retVal.font = uiConfig.fonth6
    retVal.textColor = uiConfig.sectionTitleTextColor
    retVal.backgroundColor = uiConfig.sectionTitleBackgroundColor
    retVal.textAlignment = .center
    return retVal
  }

  func signLabel (_ uiConfig:ShiftUIConfig, label:NSAttributedString) -> UILabel {
    let retVal = TTTAttributedLabel.init(frame:CGRect.zero)
    retVal.linkAttributes = [NSAttributedStringKey.foregroundColor: uiConfig.tintColor, kCTUnderlineStyleAttributeName as AnyHashable:false]
    retVal.enabledTextCheckingTypes = NSTextCheckingAllTypes
    retVal.setText(label)
    retVal.delegate = linkHandler
    return retVal
  }

}
